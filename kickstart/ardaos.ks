# ArdaOS v1 — kickstart read by livemedia-creator (build.sh fills in the @PLACEHOLDERS@ from identity.conf)

lang en_US.UTF-8
keyboard --xlayouts='@KEYBOARD_LAYOUT@'
timezone Europe/Istanbul
selinux --permissive
firewall --enabled --service=mdns
services --enabled=NetworkManager,bluetooth --disabled=sshd
network --bootproto=dhcp --device=link --activate --hostname=@HOSTNAME@
rootpw --lock
shutdown

bootloader --location=none
zerombr
clearpart --all
part / --size=14336 --fstype=ext4

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
repo --name=vscode --baseurl=https://packages.microsoft.com/yumrepos/vscode

%packages --ignoremissing
# --- base system + live boot ---
@core
kernel
kernel-modules
kernel-modules-extra
dracut-live
dracut-config-generic
-dracut-config-rescue
grub2-efi-x64
grub2-efi-x64-cdboot
grub2-pc
grub2-pc-modules
grub2-tools
grub2-tools-extra
shim-x64
syslinux
efibootmgr
isomd5sum
glibc-langpack-en
glibc-langpack-tr

# --- hardware, network, sound ---
NetworkManager
NetworkManager-wifi
NetworkManager-tui
bluez
pipewire
pipewire-pulseaudio
pipewire-alsa
wireplumber
alsa-utils
pulsemixer
mesa-dri-drivers
mesa-vulkan-drivers
spice-vdagent
qemu-guest-agent

# --- the invisible compositor + terminals ---
sway
xorg-x11-server-Xwayland
xdg-desktop-portal-wlr
kitty
foot
polkit

# --- fonts (Maple Mono + Iosevka come from GitHub in setup) ---
jetbrains-mono-fonts-all
google-noto-emoji-fonts
google-noto-sans-fonts

# --- the terminal stack ---
fish
bat
zoxide
fd-find
ripgrep
fzf
btop
neovim
fastfetch
tealdeer
git
jq
curl
unzip
tar
xz
which
less

# --- apps ---
firefox
code
podman
podman-compose
nodejs
java-21-openjdk-devel
%end

# Copy the ArdaOS layer from the repo into the image (runs on the build host)
%post --nochroot --erroronfail --log=/var/tmp/ardaos-post-nochroot.log
set -euo pipefail
ROOT="${ANA_INSTALL_PATH:-/mnt/sysimage}"
tar -C "@REPO_DIR@/rootfs" --owner=0 --group=0 -cf - . | tar -C "$ROOT" -xpf -
cp -L /etc/resolv.conf "$ROOT/etc/resolv.conf" || true
%end

# Finish the setup inside the image
%post --log=/var/log/ardaos-setup.log
bash /usr/lib/ardaos/setup-image.sh
%end
