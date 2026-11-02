#!/usr/bin/env bash
# Runs INSIDE the image during the build (kickstart %post).
# Everything here reads its names from /etc/ardaos/identity.conf.
set -uo pipefail
source /etc/ardaos/identity.conf
step() { printf '\n==> %s\n' "$*"; }

step "permissions"
chmod 755 /usr/bin/arda /usr/lib/ardaos/*.sh /usr/lib/ardaos/arda-* /usr/lib/ardaos/commands/*

step "command names"
for name in $COMMAND_NAME $EXTRA_COMMANDS; do
  [[ $name == arda ]] || ln -sf /usr/bin/arda "/usr/bin/$name"
done

step "GitHub tools + fonts"
/usr/lib/ardaos/tools.sh || echo "some tools failed — 'arda doctor' will show which"

step "keyboard for sway"
printf 'input type:keyboard {\n  xkb_layout %s\n}\n' "$KEYBOARD_LAYOUT" > /etc/ardaos/sway-keyboard

step "branding"
sed -i -e "s/^NAME=.*/NAME=\"$DISTRO_NAME\"/" \
       -e "s/^PRETTY_NAME=.*/PRETTY_NAME=\"$DISTRO_NAME (Fedora $(rpm -E %fedora) base)\"/" \
       /usr/lib/os-release
echo "$HOSTNAME" > /etc/hostname

step "user $USERNAME"
id "$USERNAME" &>/dev/null || useradd -m -G wheel -s /usr/bin/fish "$USERNAME"
echo "$USERNAME:$DEFAULT_PASSWORD" | chpasswd

step "auto-login on tty1 → terminal desktop"
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf <<EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o '-p -f -- \\\\u' --noclear --autologin $USERNAME %I \$TERM
EOF
systemctl set-default multi-user.target
systemctl enable NetworkManager bluetooth 2>/dev/null || true

step "default theme + font"
runuser -u "$USERNAME" -- env HOME="/home/$USERNAME" arda theme apply "$DEFAULT_THEME"
runuser -u "$USERNAME" -- env HOME="/home/$USERNAME" arda font apply "$DEFAULT_FONT"

step "tldr pages"
runuser -u "$USERNAME" -- env HOME="/home/$USERNAME" tldr --update >/dev/null 2>&1 || true

step "cleanup"
: > /etc/machine-id
rm -f /var/lib/systemd/random-seed
echo "done ✓"
