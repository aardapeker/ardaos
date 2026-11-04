#!/usr/bin/env bash
# ArdaOS AI core — provider adapters, config, spinner, rendering.
# Sourced by commands/ask (ai, ai chat, ai web, ai explain). Needs lib.sh first.

AI_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/ardaos/ai.conf"   # chmod 600, keys inside
# shellcheck disable=SC2034  # used by commands/ask
AI_CHAT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ardaos/chat"

# --- providers: one adapter each (same idea as Lifelog — adding one = one entry + send_<id>) ---
# id | label | default model (fast + cheap)
PROVIDERS=(
  "anthropic|Claude|claude-haiku-5-5"
  "gemini|Gemini|gemini-3.5-flash-lite"
  "openai|OpenAI-compatible (Groq, OpenRouter, Ollama…)|"
)
field() { local p; for p in "${PROVIDERS[@]}"; do [[ ${p%%|*} == "$1" ]] && { cut -d'|' -f"$2" <<< "$p"; return; }; done; }
short_label() { field "$1" 2 | cut -d' ' -f1; }

# --- config (keys per provider, one active provider) ---------------------------
# shellcheck source=/dev/null
ai_load() { if [[ -f $AI_CONF ]]; then source "$AI_CONF"; fi; }
var()     { local n="$1_$2"; printf '%s' "${!n:-}"; }      # var KEY gemini → $KEY_gemini
conf_set() {
  mkdir -p "$(dirname "$AI_CONF")"; ( umask 077; touch "$AI_CONF" ); chmod 600 "$AI_CONF"
  sed -i "/^$1=/d" "$AI_CONF"; printf '%s=%q\n' "$1" "$2" >> "$AI_CONF"
  printf -v "$1" '%s' "$2"
}
require_ai() {
  ai_load
  [[ -n ${AI_PROVIDER:-} ]] || { ui_warn "AI isn't set up yet — run: $ARDAOS_CMD ask setup"; exit 1; }
}

where_am_i() {
  if is_termux; then echo "Termux on Android (no root; use pkg, not apt/dnf; \$PREFIX is the root)"
  else echo "ArdaOS (Fedora-based Linux, sway + kitty, fish shell)"; fi
}

# --- transport ------------------------------------------------------------------
# ai_send provider system messages_json [text|json|web] → answer on stdout, "error: …" on failure.
#   messages_json = [{"role":"user"|"assistant","content":"…"}, …], first one from the user.
#   web: sources are written to the file in $AI_SOURCES as "title<TAB>url" lines.
ai_send() {
  local p=$1 out
  out=$("send_$p" "$2" "$3" "${4:-text}" "$(var KEY "$p")" "$(var MODEL "$p")" 2>&1) || true
  [[ -n ${out//[[:space:]]/} ]] || out="error: the AI sent an empty answer"
  printf '%s\n' "$out"
}

send_anthropic() {  # system msgs mode key model
  local resp
  resp=$(jq -n --arg m "$5" --arg s "$1" --argjson msgs "$2" --arg mode "$3" '
      {model:$m, max_tokens:(if $mode=="json" then 700 else 1500 end), system:$s, messages:$msgs}
      + (if $mode=="web" then {tools:[{type:"web_search_20250305", name:"web_search", max_uses:5}]} else {} end)' |
    curl -sS https://api.anthropic.com/v1/messages -H "x-api-key: $4" \
      -H "anthropic-version: 2023-06-01" -H "content-type: application/json" -d @-) \
    || { echo "error: no connection to Anthropic"; return; }
  if jq -e '.error' >/dev/null 2>&1 <<< "$resp"; then
    jq -r '"error: " + (.error.message // "unknown")' <<< "$resp"; return
  fi
  # only the text AFTER the last search result (skips "I'll search for…")
  jq -r '.content as $c
    | ([$c | to_entries[] | select(.value.type=="web_search_tool_result") | .key] | max // -1) as $i
    | [$c[($i+1):][] | select(.type=="text") | .text] | join("")' <<< "$resp"
  if [[ $3 == web && -n ${AI_SOURCES:-} ]]; then
    jq -r '[.content[] | select(.type=="text") | .citations[]? | {title, url}] | unique_by(.url) | .[]
           | "\(.title)\t\(.url)"' <<< "$resp" > "$AI_SOURCES"
    [[ -s $AI_SOURCES ]] || jq -r '[.content[] | select(.type=="web_search_tool_result")
           | (.content | arrays | .[])] | .[:6][] | "\(.title)\t\(.url)"' <<< "$resp" > "$AI_SOURCES"
  fi
}

send_gemini() {
  local resp
  resp=$(jq -n --arg s "$1" --argjson msgs "$2" --arg mode "$3" '
      {systemInstruction:{parts:[{text:$s}]},
       contents:[$msgs[] | {role:(if .role=="assistant" then "model" else "user" end), parts:[{text:.content}]}]}
      + (if $mode=="json" then {generationConfig:{responseMimeType:"application/json"}} else {} end)
      + (if $mode=="web" then {tools:[{google_search:{}}]} else {} end)' |
    curl -sS "https://generativelanguage.googleapis.com/v1beta/models/$5:generateContent" \
      -H "x-goog-api-key: $4" -H "content-type: application/json" -d @-) \
    || { echo "error: no connection to Google"; return; }
  if jq -e '.error' >/dev/null 2>&1 <<< "$resp"; then
    jq -r '"error: " + (.error.message // "unknown")' <<< "$resp"; return
  fi
  jq -r '[.candidates[0].content.parts[]?.text // empty] | join("")' <<< "$resp"
  if [[ $3 == web && -n ${AI_SOURCES:-} ]]; then
    jq -r '.candidates[0].groundingMetadata.groundingChunks[]?.web // empty | "\(.title)\t\(.uri)"' \
      <<< "$resp" > "$AI_SOURCES"
  fi
}

# shellcheck disable=SC2154  # URL_openai comes from the config file
send_openai() {
  [[ $3 == web ]] && { echo "error: web search needs Claude or Gemini — switch with: $ARDAOS_CMD ask setup"; return; }
  local resp
  resp=$(jq -n --arg m "$5" --arg s "$1" --argjson msgs "$2" \
      '{model:$m, messages:([{role:"system", content:$s}] + $msgs)}' |
    curl -sS "${URL_openai%/}/chat/completions" -H "Authorization: Bearer $4" \
      -H "content-type: application/json" -d @-) \
    || { echo "error: no connection to ${URL_openai:-the API}"; return; }
  if jq -e '.error' >/dev/null 2>&1 <<< "$resp"; then
    jq -r '"error: " + ((.error.message // .error) | tostring)' <<< "$resp"; return
  fi
  jq -r '.choices[0].message.content // empty' <<< "$resp"
}

one_msg() { jq -n --arg q "$1" '[{role:"user", content:$q}]'; }
strip_fences() { sed -e 's/^```[a-z]*//' -e 's/```$//'; }

# --- terminal helpers ------------------------------------------------------------
accent_rgb() { hex_rgb "$ARDAOS_ACCENT"; }

# spin "title" command args… → runs it in the background with a pure-bash spinner, prints its output
spin() {
  local f pid i=0 frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' rgb
  rgb=$(accent_rgb); f=$(mktemp)
  ( "${@:2}" >"$f" 2>&1 ) & pid=$!
  if [[ -t 2 ]]; then
    while kill -0 "$pid" 2>/dev/null; do
      printf '\r  \e[38;2;%sm%s\e[0m %s ' "$rgb" "${frames:i++%10:1}" "$1" >&2; sleep 0.1
    done
    printf '\r\e[K' >&2
  fi
  wait "$pid" || true
  cat "$f"; rm -f "$f"
}

render_md() {  # markdown → pretty terminal text (gum format), plain text as a fallback
  local style=dark
  [[ $(state_get THEME 2>/dev/null) == tokyo-night ]] && style=tokyo-night
  if has gum; then
    gum format --theme "$style" <<< "$1" 2>/dev/null || gum format <<< "$1" 2>/dev/null || printf '%s\n' "$1"
  else printf '%s\n' "$1"; fi
}

print_sources() {  # print_sources file
  [[ -s $1 ]] || return 0
  printf '\n  \e[1msources\e[0m\n'
  local n=0 t u
  while IFS=$'\t' read -r t u; do
    ((++n)); printf '  \e[2m%d. %s\e[0m\n     \e[2;4m%s\e[0m\n' "$n" "${t:-link}" "$u"
  done < <(head -8 "$1")
}

copy() {
  if has termux-clipboard-set; then timeout 3 termux-clipboard-set <<< "$1" || { ui_warn "clipboard needs the Termux:API app"; return; }
  elif has wl-copy; then wl-copy <<< "$1"
  else printf '%s\n' "$1"; ui_info "(no clipboard tool — select it above)"; return; fi
  ui_ok "copied"
}

looks_dangerous() {
  grep -qE '(^|[;&| ])(sudo|rm|dd|mkfs|shred|chmod|chown|mv|kill|pkill|reboot|poweroff)( |$)|>[^&]|:\(\)' <<< "$1"
}

offer_run() {  # offer_run "command" → Run / Edit / Copy / Cancel
  local cmd=$1
  printf '\n  \e[1m❯ %s\e[0m\n\n' "$cmd"
  looks_dangerous "$cmd" && ui_warn "this one changes or deletes things — read it carefully"
  case $(ui_choose "run it?" "Run" "Edit" "Copy" "Cancel") in
    Run)  bash -c "$cmd" ;;
    Edit) read -rei "$cmd" -p "  ❯ " cmd && bash -c "$cmd" ;;
    Copy) copy "$cmd" ;;
    *)    ui_info "bruh, ok. nothing ran." ;;
  esac
}

input() {  # input "placeholder" [default] [secret] [header] [prompt]
  if has gum; then
    gum input --placeholder "$1" --value "${2:-}" ${3:+--password} --width 60 \
      --header "${4:-}" --prompt "${5:-❯ }" \
      --header.foreground "$ARDAOS_ACCENT" --prompt.foreground "$ARDAOS_ACCENT" \
      --cursor.foreground "$ARDAOS_ACCENT"
  elif [[ -n ${3:-} ]]; then local v; read -rsp "$1: " v; echo >&2; echo "$v"
  else local v; read -rei "${2:-}" -p "$1: " v; echo "$v"; fi
}
