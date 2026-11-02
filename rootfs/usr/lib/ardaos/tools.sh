#!/usr/bin/env bash
# Installs what Fedora doesn't package, straight from GitHub releases.
# Used by the image build AND by `arda update`. List: $ARDAOS_SHARE/github-tools.list
set -uo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "$0")")/../.." && pwd)"   # /usr, or $PREFIX in Termux
LIST="${1:-$ROOT/share/ardaos/github-tools.list}"
BIN_DIR="${ARDAOS_BIN_DIR:-/usr/local/bin}"
FONT_DIR="${ARDAOS_FONT_DIR:-$ROOT/share/fonts/ardaos}"
KINDS="${ARDAOS_KINDS:-bin font}"   # Termux only needs fonts (its tools come from pkg)
failed=()

asset_url() {  # asset_url owner/repo regex → download URL of the latest matching asset
  curl -fsSL ${GITHUB_TOKEN:+-H "Authorization: Bearer $GITHUB_TOKEN"} \
    "https://api.github.com/repos/$1/releases/latest" |
  jq -r --arg re "$2" '[.assets[] | select(.name | test($re; "i")) | .browser_download_url][0] // empty'
}

fetch() {  # fetch url dir → downloads and unpacks into dir
  local url=$1 dir=$2 file="$2/${1##*/}"
  curl -fsSL -o "$file" "$url" || return 1
  case $file in
    *.zip)            unzip -qo "$file" -d "$dir" ;;
    *.tar.gz|*.tgz)   tar -xzf "$file" -C "$dir" ;;
    *.tar.xz)         tar -xJf "$file" -C "$dir" ;;
    *)                chmod +x "$file" ;;
  esac
}

install_one() {  # kind repo regex names
  local kind=$1 repo=$2 regex=$3 names=$4 url tmp ok=1
  # fonts never really change — don't re-download them on every update (slow on mobile data)
  if [[ $kind == font && -n $(ls -A "$FONT_DIR/${names// /-}" 2>/dev/null) ]]; then
    echo "✓ $names (already installed)"; return 0
  fi
  url=$(asset_url "$repo" "$regex")
  [[ -n $url ]] || { echo "✗ $repo: no asset matching '$regex'"; return 1; }
  tmp=$(mktemp -d)
  fetch "$url" "$tmp" || { echo "✗ $repo: download failed"; rm -rf "$tmp"; return 1; }

  if [[ $kind == bin ]]; then
    local b f
    for b in $names; do
      f=$(find "$tmp" -type f -name "$b" | head -1)
      if [[ -n $f ]]; then install -Dm755 "$f" "$BIN_DIR/$b"; else echo "✗ $repo: '$b' not in archive"; ok=0; fi
    done
  else  # font: only the 4 everyday styles, keeps the image small
    local dest="$FONT_DIR/${names// /-}"
    mkdir -p "$dest"
    find "$tmp" -type f \( -iname '*-Regular.ttf' -o -iname '*-Bold.ttf' \
      -o -iname '*-Italic.ttf' -o -iname '*-BoldItalic.ttf' \) -exec install -m644 {} "$dest/" \;
    [[ -n $(ls -A "$dest") ]] || { echo "✗ $repo: no font files found"; ok=0; }
  fi
  rm -rf "$tmp"
  ((ok)) && echo "✓ $names"
  ((ok))
}

trim() { local s=$1; s=${s#"${s%%[![:space:]]*}"}; printf '%s' "${s%"${s##*[![:space:]]}"}"; }

while IFS='|' read -r kind repo regex names; do
  kind=$(trim "$kind")
  [[ -z $kind || $kind == \#* ]] && continue
  [[ " $KINDS " == *" $kind "* ]] || continue
  names=$(trim "$names")
  install_one "$kind" "$(trim "$repo")" "$(trim "$regex")" "$names" || failed+=("$names")
done < "$LIST"

command -v fc-cache >/dev/null && fc-cache -f >/dev/null 2>&1
if ((${#failed[@]})); then echo "⚠ not installed: ${failed[*]}"; exit 1; fi
