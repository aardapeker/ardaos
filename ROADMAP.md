# ArdaOS Roadmap 🗺️

The dream: **code on the phone → test it → `ship` → live at `<name>.aardapeker.com`**, served from a home server.
Until that server exists, the Fedora laptop is "fake prod". Moving to the real server later only changes which machine runs `arda server`.

## ✅ Phase 1: code on the phone
- [x] `arda claude`: Claude Code on the laptop (official installer) and the phone (inside a small Ubuntu via proot-distro, sharing `~/projects`)
- [x] `~/projects`: one home for every app, made by the installer
- [x] `arda expo`: Expo with live reload, opens in Expo Go (or your dev build) by itself, no APK per change

## ✅ Phase 2: ship
- [x] `arda new web|api|expo <name>`: React+TS / Spring Boot / Expo with tests, CI, Containerfile and `ardaos.json`
- [x] `arda ship`: local tests → commit (AI message) → push → watch CI → phone notification
- [x] CI templates: tests in GitHub's cloud; deploy only when a server is connected (`ARDAOS_DEPLOY`)
- [x] Expo CI builds an APK and puts it on the `latest` release

## ✅ Phase 3: the laptop as fake prod
- [x] `arda server deploy`: Podman build → swap the container → health check
- [x] `arda server add <owner/repo>`: a self-hosted GitHub runner as a user service
- [x] `arda server tunnel`: Cloudflare Tunnel, `<name>.aardapeker.com`, no open ports (works behind CGNAT)
- [x] `arda server tailscale` + `connect`: the phone reaches the server anywhere

## ⏳ Phase 4: the real home server
- [ ] Buy the box (a mini PC is plenty, e.g. an N100 with 16 GB)
- [ ] ArdaOS Server Edition: the same ISO without sway and apps (headless, SSH + Podman + Tailscale)
- [ ] Move: `arda server tunnel` + `arda server add …` on the new box, the laptop is free again
- [ ] Databases in containers (Postgres) with backups

## 🔮 Phase 5: grown-up prod
- [ ] Staging: `<name>-staging.aardapeker.com` for a `dev` branch
- [ ] Rollback: `arda server rollback <app>` to the previous image
- [ ] Uptime alerts to the phone when an app goes down
- [ ] Port clash check in `arda new` (ports come from the name)

## Also on the list
- **v2 laptop:** install-to-disk, VS Code theme sync, Ghostty shaders
- **later:** LFS-based engine, same look and commands
- Chrome: still on trial ⚖️
