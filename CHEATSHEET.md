# ArdaOS Command Cheat Sheet

Every ArdaOS command with what it does. Works on the laptop and in the Pocket Edition (Termux) unless noted.

- [Start here](#start-here)
- [AI helper](#ai-helper)
- [arda commands](#arda-commands)
- [Daily shortcuts](#daily-shortcuts)
- [Silent upgrades](#silent-upgrades)
- [Tools inside](#tools-inside)
- [Tool packs](#tool-packs)
- [Laptop only](#laptop-only)
- [Phone tips and fixes](#phone-tips-and-fixes)

## Start here

If you remember only five commands, make it these.

| Command | What it does |
| --- | --- |
| `ai <what you want>` | AI writes the command for you, then Run / Edit / Copy / Cancel |
| `arda help` | Lists every arda command with a one-line description |
| `arda theme` | Switch the color theme everywhere, with a live preview while you scroll |
| `arda update` | Updates everything (on the phone: git pull + reinstall) |
| `arda doctor` | Checks that everything is installed and working |

`bruh` works anywhere you type `arda` (`bruh help`, `bruh update`).

## AI helper

Type what you want in plain English (or Turkish). The AI knows your folder and whether you are on the phone or the laptop.

| Command | What it does |
| --- | --- |
| `ai <text>` | Ask for a command, e.g. `ai find the 5 biggest files here` |
| `? <text>` | Same as `ai` (shortcut) |
| `arda ask setup` | Pick Claude, Gemini or an OpenAI-compatible API, paste the key, test it |
| `arda ask status` | Shows which AI is active and which keys are saved |
| `arda ask test` | Prints the raw answer from the AI, for debugging |

After each answer you choose:

- **Run**: runs the command now
- **Edit**: lets you change it first
- **Copy**: copies it to the clipboard
- **Cancel**: nothing happens

Commands that delete or change things (`rm`, `sudo`, `dd`, `mv`) get a warning first. Keys are stored only on your device, in a file only you can read.

## arda commands

Every system command lives under `arda`.

| Command | What it does |
| --- | --- |
| `arda theme` | Menu of themes with a live preview. Enter applies, Esc cancels |
| `arda theme apply tokyo-night` | Apply a theme directly: `tokyo-night`, `catppuccin-mocha`, `rose-pine`, `gruvbox-dark` |
| `arda theme list` / `current` / `name` | List themes, show the active one's id, or its full name |
| `arda font` | Menu of fonts: JetBrains Mono, Maple Mono, Iosevka |
| `arda font apply "Maple Mono"` | Apply a font directly |
| `arda font list` / `current` | List fonts or show the active one |
| `arda go` | App launcher menu (shows only apps that exist on this device) |
| `arda go web` | Open one app directly by its short name |
| `arda pack list` | Show the optional tool packs |
| `arda pack show hacker` | Show what a pack contains (installs nothing) |
| `arda pack install hacker` | Install a pack: `hacker`, `dev` or `network` |
| `arda cams` | Find IP cameras & NVRs on a network (needs the `network` pack) |
| `arda update` | Phone: git pull + reinstall. Laptop: dnf upgrade + GitHub tools |
| `arda doctor` | Green or red check for every tool, font and system part |
| `arda power` | Shutdown, reboot, sleep or log out (laptop) |
| `arda help` | List all commands |

## Daily shortcuts

Short words for the things you open most.

| Type | Opens | Where |
| --- | --- | --- |
| `go` | App launcher (same as `arda go`) | both |
| `files` | yazi, the file manager | both |
| `lg` | lazygit, git in a TUI | both |
| `sys` | System monitor: btop on the laptop, htop on the phone | both |
| `cheat <tool>` | Short examples, e.g. `cheat tar` | both |
| `web` | Firefox | laptop |
| `music` | spotify_player (needs Spotify Premium) | laptop |
| `wifi` | Wi-Fi menu (nmtui) | laptop |
| `vol` | Volume mixer (pulsemixer) | laptop |
| `home` | Jump back to the home terminal | laptop |

## Silent upgrades

The classic commands you already know, quietly swapped for prettier versions.

| Type | Now runs | What changes |
| --- | --- | --- |
| `ls` | eza | Icons and colors, folders first |
| `ll` | eza -la | Detailed list with git status |
| `tree` | eza --tree | Folder tree with icons |
| `cat file` | bat | Syntax highlighting |
| `cd name` | zoxide | Jumps to folders you visited before, from anywhere: `cd ardaos` |
| `Ctrl + R` | history search | atuin on the laptop, fish's built-in search on the phone |

## Tools inside

The programs underneath, with the one key you need to get out of each.

| Tool | What it does | Try | Quit |
| --- | --- | --- | --- |
| yazi | File manager with previews | `files` | `q` |
| lazygit | Git: stage, commit, push with keys | `lg` inside a repo | `q` |
| neovim | Text editor | `nvim README.md` | `Esc`, then `:q` |
| zellij | Split the terminal into panes and tabs | `zellij` | `Ctrl + q` |
| htop / btop | System monitor | `sys` | `q` |
| fzf | Fuzzy search in any list | `ls \| fzf` | `Esc` |
| ripgrep | Search text inside files, fast | `rg TODO` | |
| fd | Find files by name, fast | `fd .sh` | |
| tldr | Short examples for any command | `cheat git` | |
| fastfetch | The Şemistan home screen | `fastfetch` | |

## Tool packs

Optional extras. Install with `arda pack install <name>`.

### hacker

Network and security tools. Only use them on networks you own or are allowed to test.

| Command | What it does | Example |
| --- | --- | --- |
| `nmap` | Finds devices and open ports (phone: use `-sT`) | `nmap -sT 192.168.1.0/24` |
| `nc` | Raw TCP/UDP connections | `nc -zv 192.168.1.10 554` |
| `dig` | DNS lookup | `dig github.com` |
| `whois` | Who owns a domain or IP | `whois google.com` |
| `traceroute` | Path packets take to a host | `traceroute 8.8.8.8` |
| `openssl` | Inspect TLS certificates | `openssl s_client -connect github.com:443` |
| `http` | Friendly HTTP requests | `http GET httpbin.org/get` |
| `cmatrix` | Matrix rain | `cmatrix -C blue` |

Laptop only: `mtr` (live traceroute), `tcpdump` and `tshark` (packet capture, need root).

### dev

TypeScript and Java kit. Java is the big download, so use Wi-Fi.

| Command | What it does | Example |
| --- | --- | --- |
| `node` / `npm` | Node.js and its package manager | `npm create vite@latest` |
| `tsc` | TypeScript compiler | `tsc app.ts` |
| `tsx` | Run a .ts file directly | `tsx hi.ts` |
| `java` / `javac` | Java 21 | `java Hello.java` |
| `mvn` | Maven, for Spring Boot | `./mvnw spring-boot:run` |
| `gradle` | Gradle (phone only) | `gradle build` |
| `gh` | GitHub CLI | `gh auth login` |

React on the phone: `npm run dev -- --host`, then open `localhost:5173` in the phone's browser.

### network

Network and camera toolkit. Install, then `arda cams` finds cameras for you.

| Command | What it does | Example |
| --- | --- | --- |
| `arda cams` | Scan a network for cameras & NVRs, show likely brand and open ports | `arda cams 192.168.1.0/24` |
| `ffprobe` | Inspect an RTSP stream: codec, resolution, fps, bitrate | `ffprobe rtsp://user:pass@IP:554/` |
| `mpv` | Watch a live camera stream (laptop) | `mpv rtsp://user:pass@IP:554/` |
| `ipcalc` | Subnet calculator | `ipcalc 192.168.1.0/24` |
| `fping` | Ping many IPs at once | `fping -a -g 192.168.1.0/24` |
| `age` | Simple file encryption | `age -p secret.txt > secret.age` |
| `wg` | Your own VPN (WireGuard) | |

Laptop only: `arp-scan` (devices + vendor from MAC), `termshark` (Wireshark TUI), `bandwhich` (live bandwidth per app), `iperf3` (link speed).

## Laptop only

The full ArdaOS (sway + kitty) adds keyboard shortcuts. Super is the Windows key.

| Keys | What it does |
| --- | --- |
| `Super + Space` | Floating app launcher |
| `Super + Esc` or `Super + H` | Back to the home terminal |
| `Super + Tab` / `Super + Shift + Tab` | Next / previous app |
| `Super + 1` to `5` | Jump to a workspace (1 = home, 2 = Firefox, 3 = VS Code, 4 = terminal apps) |
| `Super + Q` | Close the current app |
| `Super + F` | Fullscreen |
| `Super + Shift + E` | Power menu |
| `Super + Shift + R` | Reload the sway config |

Build the ISO on Fedora:

```bash
git clone https://github.com/aardapeker/ardaos
cd ardaos
./build.sh
```

It needs about 15 GB free and takes 20 to 40 minutes. The result is `out/ardaos.iso`; open it in GNOME Boxes with 3D acceleration on. Login: user `arda`, password `arda`.

## Phone tips and fixes

The Pocket Edition runs inside Termux.

| Problem | Fix |
| --- | --- |
| A new command or alias is "not found" | `arda update`, then `exec fish` |
| Want to stop a running command | Tap `CTRL` on the extra-keys row, then `c` |
| Paste a command | Long-press the screen, then Paste |
| Package says "Unable to locate" | It isn't in Termux; ask with `pkg search <word>` |
| Upgrade asks Y/I/N/O/D/Z | Press Enter (keeps the default) |
| Free up space | `pkg clean` (deletes downloaded package files) |
| Check how much space it uses | `du -sh $PREFIX ~` |
| htop shows "offline" CPUs | Normal: Android hides CPU details from apps |

Not available on the phone: Firefox, VS Code, spotify_player, sway shortcuts, btop, atuin.
