# ArdaOS shell defaults (system-wide). Your own stuff → ~/.config/fish/config.fish

# Log in on tty1 → start the terminal desktop
if status is-login; and test (tty) = /dev/tty1; and not set -q WAYLAND_DISPLAY; and not set -q ARDAOS_NO_SESSION
    /usr/lib/ardaos/arda-session
    or echo "⚠ the graphical session failed — you're in the plain console. Try: arda doctor"
end

status is-interactive; or return

# home screen: Şemistan + hints
function fish_greeting
    if command -q fastfetch
        # narrow phone screen: Şemistan on top, info below (no ugly line wrapping)
        if set -q TERMUX_VERSION; or test $COLUMNS -lt 70
            fastfetch --logo-position top
        else
            fastfetch
        end
    end
    set_color $fish_color_autosuggestion
    echo "  ai · go · files · lg · sys · arda help"
    set_color normal
end

# modern replacements — same muscle memory, prettier output
if command -q eza
    alias ls 'eza --icons --group-directories-first'
    alias ll 'eza -la --icons --git --group-directories-first'
    alias tree 'eza --tree --icons'
end
command -q bat; and alias cat 'bat --paging=never'
set -gx BAT_THEME ansi
command -q fd; or alias fd fdfind
command -q zoxide; and zoxide init fish --cmd cd | source
command -q starship; and starship init fish | source
# atuin can't create its key file on Android — the phone uses fish's own Ctrl+R
if command -q atuin; and not set -q TERMUX_VERSION
    atuin init fish --disable-up-arrow | source
end

# daily verbs
alias go 'arda go'
alias web 'arda go web'
alias music spotify_player
alias files yazi
alias lg lazygit
# system monitor: btop on the desktop, htop in Termux (no btop package there)
for m in btop btm htop
    if command -q $m; alias sys $m; break; end
end
alias wifi nmtui
alias vol pulsemixer
alias cheat tldr
alias home 'swaymsg workspace 1 >/dev/null'

# AI helper: ai find big files  (or: ? find big files)
alias ai 'arda ask'
abbr -a -- '?' 'arda ask' 2>/dev/null
