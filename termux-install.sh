#!/usr/bin/env bash
# ArdaOS Pocket Edition 📱 — the ArdaOS look and commands inside Termux.
#   pkg install git && git clone https://github.com/aardapeker/ardaos && cd ardaos
#   ./termux-install.sh
# Run it again any time to update.
set -euo pipefail

say()  { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
warn() { printf '\e[33m!\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m✗ %s\e[0m\n' "$*" >&2; exit 1; }

[[ -n ${TERMUX_VERSION:-} && -n ${PREFIX:-} ]] || die "Run this inside Termux on your phone."
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOTFS="$REPO/rootfs"
# shellcheck source=rootfs/etc/ardaos/identity.conf
source "$ROOTFS/etc/ardaos/identity.conf"

# --- 1. packages (one by one, so one missing package doesn't stop the rest) ---
say "Upgrading Termux first (mixing old and new packages breaks things)…"
# fresh Termux: take the new config files instead of asking Y/N for each one
pkg upgrade -y -o Dpkg::Options::="--force-confnew"

say "Installing the terminal stack…"
for p in fish starship eza bat zoxide fd ripgrep fzf yazi lazygit htop neovim gum \
         fastfetch tealdeer zellij git jq curl unzip xz-utils procps termux-tools; do
  printf '\n\e[1m── %s ──\e[0m\n' "$p"   # visible output: big downloads shouldn't look frozen
  pkg install -y -o Dpkg::Options::="--force-confnew" "$p" || warn "couldn't install $p (skipping)"
done

# --- 2. the ArdaOS layer: same files as the ISO, just under $PREFIX ----------
say "Copying ArdaOS…"
install -Dm755 "$ROOTFS/usr/bin/arda" "$PREFIX/bin/arda"
for name in $COMMAND_NAME $EXTRA_COMMANDS; do
  [[ $name == arda ]] || ln -sf "$PREFIX/bin/arda" "$PREFIX/bin/$name"
done
rm -rf "$PREFIX/lib/ardaos" "$PREFIX/share/ardaos"
cp -r "$ROOTFS/usr/lib/ardaos"   "$PREFIX/lib/ardaos"
cp -r "$ROOTFS/usr/share/ardaos" "$PREFIX/share/ardaos"
chmod 755 "$PREFIX"/lib/ardaos/*.sh "$PREFIX"/lib/ardaos/commands/*
mkdir -p "$PREFIX/etc/ardaos" "$PREFIX/etc/fish/conf.d"
cp "$ROOTFS/etc/ardaos/identity.conf" "$PREFIX/etc/ardaos/"
echo "$REPO" > "$PREFIX/etc/ardaos/repo"   # so `arda update` knows where to git pull
cp "$ROOTFS/etc/fish/conf.d/ardaos.fish" "$PREFIX/etc/fish/conf.d/"

# your personal configs: only added if you don't have them yet
mkdir -p "$HOME/.config"
for d in fish nvim btop; do
  cp -rn "$ROOTFS/etc/skel/.config/$d" "$HOME/.config/" 2>/dev/null || true
done

# --- 3. fonts from GitHub ------------------------------------------------------
say "Downloading fonts…"
ARDAOS_KINDS=font "$PREFIX/lib/ardaos/tools.sh" || warn "some fonts failed (arda doctor shows which)"

# --- 4. fish as the shell, default theme + font --------------------------------
chsh -s fish || warn "couldn't switch the shell to fish"
arda theme apply "$DEFAULT_THEME"
arda font apply "$DEFAULT_FONT" || true
tldr --update >/dev/null 2>&1 || true
touch "$HOME/.hushlogin"   # hide Termux's welcome text — Şemistan is the welcome now

say "Done! Close Termux completely and open it again. Şemistan is waiting 🐈"
echo "   Try: arda theme · arda font · arda doctor"
