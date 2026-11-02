#!/usr/bin/env bash
# ArdaOS shared helpers — sourced by every arda command. Keep UI logic HERE (DRY).

ARDAOS_ETC="${ARDAOS_ETC:-/etc/ardaos}"
ARDAOS_LIB="${ARDAOS_LIB:-/usr/lib/ardaos}"
ARDAOS_SHARE="${ARDAOS_SHARE:-/usr/share/ardaos}"
ARDAOS_STATE="${XDG_CONFIG_HOME:-$HOME/.config}/ardaos/state"

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
