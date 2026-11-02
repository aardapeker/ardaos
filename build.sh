#!/usr/bin/env bash
# ArdaOS v1 builder — run this on Fedora. It produces out/ardaos.iso.
#   ./build.sh
# Needs: Fedora, sudo, internet, ~15 GB free in /var/tmp. Takes ~20–40 min.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=rootfs/etc/ardaos/identity.conf
source "$REPO_DIR/rootfs/etc/ardaos/identity.conf"

RELEASEVER="${RELEASEVER:-$(rpm -E %fedora 2>/dev/null || echo 0)}"
WORK="/var/tmp/${DISTRO_ID}-build"
OUT="$REPO_DIR/out"
ISO_NAME="${DISTRO_ID}.iso"

say()  { printf '\e[1;34m==>\e[0m %s\n' "$*"; }
die()  { printf '\e[1;31m✗ %s\e[0m\n' "$*" >&2; exit 1; }

# --- 1. sanity checks -------------------------------------------------------
[[ -f /etc/fedora-release ]] || die "This builder runs on Fedora only."
[[ $EUID -ne 0 ]] || die "Run it as your normal user (it calls sudo itself)."
[[ $RELEASEVER =~ ^[0-9]+$ && $RELEASEVER -gt 0 ]] || die "Could not detect the Fedora version."
free_gb=$(df --output=avail -BG /var/tmp | tail -1 | tr -dc '0-9')
(( free_gb >= 15 )) || die "Need ~15 GB free in /var/tmp (you have ${free_gb} GB)."

say "Building ${DISTRO_NAME} on Fedora ${RELEASEVER}"
sudo -v

# --- 2. build tools ---------------------------------------------------------
say "Installing build tools (lorax, livemedia-creator)…"
sudo dnf install -y lorax lorax-lmc-novirt pykickstart

# --- 3. prepare the kickstart -----------------------------------------------
sudo rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
sed -e "s|@REPO_DIR@|$REPO_DIR|g" -e "s|@KEYBOARD_LAYOUT@|$KEYBOARD_LAYOUT|g" -e "s|@HOSTNAME@|$HOSTNAME|g" \
  "$REPO_DIR/kickstart/ardaos.ks" > "$WORK/ardaos.ks"
ksvalidator "$WORK/ardaos.ks" || die "Kickstart is invalid (see above)."

# --- 4. SELinux must be permissive while livemedia-creator runs -------------
selinux_was=$(getenforce 2>/dev/null || echo Disabled)
restore_selinux() { [[ $selinux_was == Enforcing ]] && sudo setenforce 1 || true; }
trap restore_selinux EXIT
[[ $selinux_was == Enforcing ]] && { say "Setting SELinux to permissive for the build (restored after)"; sudo setenforce 0; }

# --- 5. build ----------------------------------------------------------------
say "Building the image. Grab a tea, this takes a while ☕"
# --nomacboot: developer principle #2 😏
sudo livemedia-creator \
  --make-iso --no-virt --iso-only --nomacboot \
  --ks "$WORK/ardaos.ks" \
  --project "$DISTRO_NAME" --releasever "$RELEASEVER" \
  --volid "${DISTRO_ID^^}" --iso-name "$ISO_NAME" \
  --resultdir "$WORK/result" --logfile "$WORK/lmc.log" --tmp /var/tmp \
  || die "Build failed. Send Claude the end of: $WORK/lmc.log and /var/tmp/*/anaconda/*.log"

# --- 6. hand it over ----------------------------------------------------------
sudo mv "$WORK/result/$ISO_NAME" "$OUT/$ISO_NAME"
sudo chown "$(id -u):$(id -g)" "$OUT/$ISO_NAME"
say "Done! → $OUT/$ISO_NAME"
echo "   Open GNOME Boxes → + → Install from file → pick the ISO. Turn on 3D acceleration."
