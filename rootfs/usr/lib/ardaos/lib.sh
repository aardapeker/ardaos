#!/usr/bin/env bash
# ArdaOS shared helpers — sourced by every arda command. Keep UI logic HERE (DRY).

# Paths are relative to where arda is installed, so the same code runs on
# Fedora (/usr/...) and in Termux ($PREFIX/...). /etc is the one exception.
ARDAOS_LIB="${ARDAOS_LIB:-/usr/lib/ardaos}"
_root="$(cd "$ARDAOS_LIB/../.." && pwd)"
ARDAOS_SHARE="${ARDAOS_SHARE:-$_root/share/ardaos}"
if [[ -z ${ARDAOS_ETC:-} ]]; then
  if [[ -d /etc/ardaos ]]; then ARDAOS_ETC=/etc/ardaos; else ARDAOS_ETC="$_root/etc/ardaos"; fi
fi
ARDAOS_FONT_DIR="${ARDAOS_FONT_DIR:-$_root/share/fonts/ardaos}"
ARDAOS_STATE="${XDG_CONFIG_HOME:-$HOME/.config}/ardaos/state"
export ARDAOS_LIB ARDAOS_SHARE ARDAOS_ETC ARDAOS_FONT_DIR

is_termux() { [[ -n ${TERMUX_VERSION:-} ]]; }

# Fonts: Nerd Font versions, so icons work everywhere (yazi, eza, starship), phone included.
# display name | folder (= name in github-tools.list) | font family name
ARDAOS_FONTS=(
  "JetBrains Mono|JetBrainsMono-NF|JetBrainsMono Nerd Font"
  "Maple Mono|MapleMono-NF|Maple Mono NF"
  "Iosevka|Iosevka-NF|Iosevka Nerd Font"
)
# shellcheck disable=SC2034  # FONT_DIRNAME/FONT_FAMILY are read by the commands
font_lookup() {  # font_lookup "display name" → sets FONT_DIRNAME, FONT_FAMILY
  local f
  for f in "${ARDAOS_FONTS[@]}"; do
    if [[ ${f%%|*} == "$1" ]]; then IFS='|' read -r _ FONT_DIRNAME FONT_FAMILY <<< "$f"; return 0; fi
  done
  return 1
}

# shellcheck source=../../../etc/ardaos/identity.conf
[[ -f $ARDAOS_ETC/identity.conf ]] && source "$ARDAOS_ETC/identity.conf"
ARDAOS_CMD="${ARDAOS_CMD:-${COMMAND_NAME:-arda}}"
ARDAOS_ACCENT="${ARDAOS_ACCENT:-#7aa2f7}"

has() { command -v "$1" >/dev/null 2>&1; }

# --- UI (pretty with gum, still works without it) ---------------------------
ui_title() {
  if has gum; then
    gum style --border rounded --padding "0 2" --margin "1 0" --bold \
      --border-foreground "$ARDAOS_ACCENT" "$*"
  else
    printf '\n\e[1m== %s ==\e[0m\n\n' "$*"
  fi
}
ui_ok()   { printf '  \e[32m✓\e[0m %s\n' "$*"; }
ui_fail() { printf '  \e[31m✗\e[0m %s\n' "$*"; }
ui_warn() { printf '  \e[33m!\e[0m %s\n' "$*"; }
ui_info() { printf '  \e[2m%s\e[0m\n' "$*"; }

ui_choose() {  # ui_choose "header" option...
  local header=$1; shift
  if has gum; then gum choose --header "$header" "$@"
  elif has fzf; then printf '%s\n' "$@" | fzf --prompt "$header > "
  else select o in "$@"; do echo "$o"; break; done
  fi
}

ui_confirm() {
  if has gum; then gum confirm "$1"
  else local a; read -rp "$1 [y/N] " a; [[ $a == [yY]* ]]
  fi
}

ui_spin() {  # ui_spin "title" command args...
  local title=$1; shift
  if has gum; then gum spin --spinner dot --show-error --title " $title" -- "$@"
  else echo "… $title"; "$@"
  fi
}

# --- per-user state (current theme, font) -----------------------------------
state_get() { [[ -f $ARDAOS_STATE ]] && sed -n "s/^$1=//p" "$ARDAOS_STATE" | tail -1; }
state_set() {
  mkdir -p "$(dirname "$ARDAOS_STATE")"
  touch "$ARDAOS_STATE"
  sed -i "/^$1=/d" "$ARDAOS_STATE"
  printf '%s=%s\n' "$1" "$2" >> "$ARDAOS_STATE"
}

in_sway() { [[ -n ${SWAYSOCK:-} ]] && has swaymsg; }
