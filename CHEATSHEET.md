# ArdaOS Command Cheat Sheet

Every ArdaOS command with what it does. Works on the laptop and in the Pocket Edition (Termux) unless noted.

- [Start here](#start-here)
- [AI helper](#ai-helper)
- [arda commands](#arda-commands)
- [Daily shortcuts](#daily-shortcuts)
- [Silent upgrades](#silent-upgrades)
- [Tools inside](#tools-inside)
- [Share files](#share-files)
- [Camera finder](#camera-finder)
- [Tool packs](#tool-packs)
- [Laptop only](#laptop-only)
- [Phone extras](#phone-extras)
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

**First start:** a setup wizard asks about theme, font, tool packs, AI and phone or laptop extras. It runs once by itself; `arda setup` brings it back any time.

## AI helper

Type what you want in plain English (or Turkish). The AI knows your folder and whether you are on the phone or the laptop.

| Command | What it does |
| --- | --- |
| `ai <text>` | Ask for a command, e.g. `ai find the 5 biggest files here` |
| `? <text>` | Same as `ai` (shortcut) |
| `ai chat` | A real conversation that remembers what you said, even next time |
| `ai web <question>` | Searches the web and answers with sources (Claude or Gemini) |
| `ai explain` | Explains an error and suggests the fix (see below) |
| `arda ask setup` | Pick Claude, Gemini or an OpenAI-compatible API, paste the key, test it |
| `arda ask status` | Shows which AI is active and which keys are saved |
| `arda ask test` | Prints the raw answer from the AI, for debugging |

After each answer you choose:

- **Run**: runs the command now
- **Edit**: lets you change it first
- **Copy**: copies it to the clipboard
- **Cancel**: nothing happens

Commands that delete or change things (`rm`, `sudo`, `dd`, `mv`) get a warning first. Keys are stored only on your device, in a file only you can read.

### ai chat

Type `ai chat` and talk. It continues your last conversation; type these inside the chat:

| Type | What it does |
| --- | --- |
| `/new` | Start a fresh chat (the old one is kept in `~/.config/ardaos/chat/history`) |
| `/about` | Write what the AI should know about you; it reads this before every answer |
| `/web <question>` | Search the web inside the chat |
| `/copy` | Copy the last answer |
| `/exit` | Leave (Esc or Ctrl+C work too) |

### ai explain

Three ways to give it an error:

| How | Example |
| --- | --- |
| Pipe a command into it | `npm run build &\| ai explain` (`&\|` sends errors too) |
| Type or paste it as text | `ai explain "permission denied: ./build.sh"` |
| Paste it after running | `ai explain`, paste, press Enter, then Ctrl+D |

You get **What happened**, **Why** and **Fix**, and if one command fixes it: Run / Edit / Copy / Cancel.

`ai web` costs a little per search on your API account (cents). OpenAI-compatible APIs can't search; use Claude or Gemini for it.

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
| `arda pack install hacker` | Install a pack: `hacker`, `network`, `security` or `dev` |
| `arda pack install all` | Install every pack (short form: `arda install all`) |
| `arda setup` | The setup wizard again: theme, font, packs, AI, phone/laptop extras |
| `arda share <file>` | Send a file or folder over Wi-Fi (see Share files) |
| `arda share receive` | Get files from another device over Wi-Fi |
| `arda status` | Battery, Wi-Fi, IP, storage and memory |
| `arda lock` | Lock the screen (laptop; also Super + L) |
| `arda buttons` | Create the phone's home-screen buttons |
| `arda cams` | Find IP cameras and NVRs on your network (see Camera finder) |
| `arda audit <ip>` | Safe security checkup of one device you own (see Camera finder) |
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

## Share files

Phone and laptop on the same Wi-Fi, no cables, no WhatsApp-to-yourself.

| Command | What it does |
| --- | --- |
| `arda share photo.jpg` | Shows a link and a QR code; open it on the other device to download |
| `arda share ~/projects/app` | Shares a whole folder as a download page |
| `arda share receive` | Shows an upload page link; pick files on the other device and they land here |
| `arda share receive ~/somewhere` | Same, into a folder you choose |
| `arda share get <link>` | Download a shared file from the terminal |

Files land in Downloads (phone: run `termux-setup-storage` once so they go to the phone's Downloads folder). Each link has a random code, so other people on the Wi-Fi can't guess it. Ctrl+C stops sharing.

Phone paths: photos are in `~/storage/dcim`, downloads in `~/storage/downloads` (after `termux-setup-storage`).

## Camera finder

`arda cams` scans your network for IP cameras and NVRs. Install the `network` pack first. Only scan networks you own or are working on.

| Command | What it does |
| --- | --- |
| `arda cams` | Scans your current network (it finds the /24 by itself) |
| `arda cams 10.0.0.0/24` | Scans a network you choose |
| `arda cams --mac` | Also shows the vendor from each MAC address (laptop, asks for sudo) |

For every device it shows the brand (Hikvision, Dahua, XMEye, Axis, Uniview, Reolink, or a guess with `?`), and whether RTSP (554), the web page and ONVIF answer. At the end it prints a ready RTSP URL for the first camera, with the commands to check and watch it:

```bash
ffprobe -rtsp_transport tcp "rtsp://USER:PASS@192.168.1.64:554/Streaming/Channels/101"
mpv "rtsp://USER:PASS@192.168.1.64:554/Streaming/Channels/101"      # phone: mpv --vo=tct …
```

Brand guesses come from the web page, the server header and typical ports: 8000 = Hikvision, 37777 = Dahua, 34567 = XMEye.

### Security checkup

`arda audit 192.168.1.64` checks one device you own and lists what to fix. It is read-only: it never logs in or changes anything.

| It checks | Why it matters |
| --- | --- |
| All open TCP ports | Every open port is a door; close the ones you don't use |
| Telnet (23), FTP (21), port 2323 | Old, unencrypted services that leak passwords |
| RTSP (554) without a password | Anyone on the network could watch the camera |
| Weak or old TLS on 443/8443 | Outdated encryption on the HTTPS admin page |
| Admin page on plain HTTP (80) | Your password crosses the network unencrypted |
| Default passwords (reminder) | The number one way cameras get taken over |

## Tool packs

Optional extras. Install with `arda pack install <name>`, or everything at once with `arda pack install all`.

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

Laptop only:

| Command | What it does | Example |
| --- | --- | --- |
| `mtr` | Live traceroute with packet loss per hop | `mtr 8.8.8.8` |
| `arp-scan` | Every device on the LAN with its vendor | `sudo arp-scan -l` |
| `tcpdump` | Captures packets | `sudo tcpdump -i any port 554` |
| `tshark` | Wireshark in the terminal | `sudo tshark -i any -f "port 554"` |
| `termshark` | Wireshark with a real TUI | `sudo termshark -i any` |
| `bandwhich` | Which app or IP uses your bandwidth, live | `sudo bandwhich` |

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

Camera and network field kit. Includes `nmap`, so `arda cams` works.

| Command | What it does | Example |
| --- | --- | --- |
| `ffprobe` | Checks an RTSP stream: resolution, codec, FPS, bitrate | `ffprobe -rtsp_transport tcp "rtsp://…"` |
| `mpv` | Watches a stream (phone: `--vo=tct` draws it in the terminal) | `mpv "rtsp://…"` |
| `ipcalc` | Subnet calculator | `ipcalc 192.168.1.0/24` |
| `fping` | Pings a whole range at once | `fping -a -g 192.168.1.0/24` |
| `speedtest` | Internet speed test | `speedtest` |
| `iperf3` | Real speed between two devices | `iperf3 -s` on one, `iperf3 -c <ip>` on the other |

### security

Protect yourself.

| Command | What it does | Example |
| --- | --- | --- |
| `lynis` | Audits this system and suggests fixes (laptop) | `sudo lynis audit system` |
| `wg` / `wg-quick` | WireGuard VPN | `sudo wg-quick up wg0` |
| `age` | Simple file encryption | `age -p secret.txt > secret.txt.age` |
| `gpg` | Classic encryption and signing | `gpg -c file.txt` |
| `pass` | Password manager in the terminal | `pass insert email/gmail` |

Some phone packages may not exist in Termux; the installer skips them and says so.

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
| `Super + L` | Lock the screen |

The screen also locks after 10 minutes idle, turns off after 15, and always locks before sleep. The lock screen shows Şemistan in your current theme's colors. Notifications appear top right.

Build the ISO on Fedora:

```bash
git clone https://github.com/aardapeker/ardaos
cd ardaos
./build.sh
```

It needs about 15 GB free and takes 20 to 40 minutes. The result is `out/ardaos.iso`; open it in GNOME Boxes with 3D acceleration on. Login: user `arda`, password `arda`.

## Phone extras

Two small add-on apps unlock more on the phone. Get them from **F-Droid, the same place you got Termux** (mixing sources breaks them).

| App | Unlocks | Then |
| --- | --- | --- |
| Termux:API | Battery and Wi-Fi in `arda status` and on the home screen, notifications, clipboard | Give it Location permission to see the Wi-Fi name |
| Termux:Widget | Home-screen buttons: ArdaOS, AI chat, Ask AI, Find cameras, Receive files, Status, Update, Matrix | Long-press the home screen → Widgets → Termux:Widget |

Change the buttons: edit `$PREFIX/share/ardaos/buttons.list` (or add your own scripts to `~/.shortcuts`), then run `arda buttons`.

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
