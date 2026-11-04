```
      /\_____/\
     /  o   o  \      ArdaOS
    ( ==  ^  == )     the terminal is the desktop
     )         (
    (           )
   ( (  )   (  ) )
  (__(__)___(__)__)
```

A personal, terminal-first Linux. No GNOME, no KDE, no taskbar. You boot into a
beautiful fullscreen terminal and launch everything from there.

**v1** is a live ISO built on a minimal Fedora base. Later versions may swap the
base for a from-scratch (LFS) one. The look and the commands stay the same.

## Build the ISO (on Fedora)

```bash
git clone https://github.com/aardapeker/ardaos
cd ardaos
./build.sh
```

- Needs sudo, internet and **~15 GB free in `/var/tmp`**. Takes 20–40 minutes.
- SELinux is set to permissive *only while building*, then restored.
- Result: `out/ardaos.iso`

## Try it in GNOME Boxes

1. Boxes → **+** → **Install from File** → pick `out/ardaos.iso`.
2. Before starting it: properties → turn **3D acceleration on** (for kitty's animations).
   Give it 4 GB RAM or more.
3. Boot. It logs in automatically as `arda` and opens the home terminal.

User `arda`, password `arda` (change it with `passwd`).
It's a **live** system: changes are lost when you reboot. That's fine for testing.

> In Boxes, Fedora may grab the Super key. Click inside the VM first, or just use the commands below.

## Commands

📋 **Full list with explanations and examples: [CHEATSHEET.md](CHEATSHEET.md)**

| | |
|---|---|
| `ai <what you want>` | AI writes the command → Run / Edit / Copy. Claude, Gemini or any OpenAI-compatible API (`arda ask setup`) |
| `arda help` | everything ArdaOS can do (`bruh help` works too 😏) |
| `arda theme` | switch theme everywhere, **live preview** while you scroll |
| `arda font` | JetBrains Mono · Maple Mono · Iosevka |
| `arda go` | app launcher (`arda go web` opens one directly) |
| `arda update` | system + tools update |
| `arda doctor` | checks that everything works |
| `arda power` | shutdown / reboot / sleep / log out |
| `arda pack` | extra tool packs: `hacker` (network tools), `dev` (Node, TypeScript, Java 21, Maven, gh) |

Shortcuts: `ai` `go` `web` `music` `files` `lg` `sys` `wifi` `vol` `cheat` `home`

Keys: `Super+Space` launcher · `Super+Esc` home terminal · `Super+Tab` next app ·
`Super+Q` close · `Super+F` fullscreen · `Super+Shift+E` power menu

## What's inside

**Look:** sway (invisible) → kitty fullscreen (cursor trail, transparency) → fish +
starship. Themes: Tokyo Night (default), Catppuccin Mocha, Rosé Pine, Gruvbox Dark.

**Terminal tools:** eza, bat, zoxide, fd, ripgrep, fzf, yazi, lazygit, btop, neovim,
zellij, atuin, gum, tealdeer, fastfetch.

**Apps:** Firefox, VS Code, spotify_player, Podman (+ compose), Node.js, Java 21.

## 📱 ArdaOS Pocket Edition (Android)

Same look and commands on your phone, inside [Termux](https://termux.dev) (install it from F-Droid or GitHub, not the old Play Store version):

```bash
pkg install git
git clone https://github.com/aardapeker/ardaos && cd ardaos
./termux-install.sh
```

Then close and reopen Termux. `arda theme` live-previews right on the phone screen.
No GUI apps here, just the terminal stack. Run it again any time to update.

## How it's organized

```
build.sh                 builds the ISO (runs on your Fedora)
termux-install.sh        Pocket Edition for Android (Termux)
CHEATSHEET.md            every command, explained
kickstart/ardaos.ks      package list + build steps
rootfs/                  copied as-is into the image
  etc/ardaos/identity.conf   ← the name lives ONLY here (rename = edit + rebuild)
  usr/bin/arda               the main command
  usr/lib/ardaos/commands/   one small script per subcommand
  usr/share/ardaos/themes/   one palette file per theme
  usr/share/ardaos/templates/  app configs with {{color}} placeholders
```

**Add a theme:** copy a file in `themes/`, change the colors. Done. Every app follows.
**Add a command:** drop a script in `commands/` with a `# desc:` line. It shows up in `arda help`.

## When the build fails

That's normal for a v1. Send the last ~50 lines of `/var/tmp/ardaos-build/lmc.log`
(and any `anaconda` log mentioned there) and it gets fixed.

## Roadmap

- **v2:** install-to-disk, VS Code theme sync, Ghostty shaders
- **later:** LFS-based engine, same look and commands
- Chrome: still on trial ⚖️
