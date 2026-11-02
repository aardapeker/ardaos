# ArdaOS shell defaults (system-wide). Your own stuff → ~/.config/fish/config.fish

# Log in on tty1 → start the terminal desktop
if status is-login; and test (tty) = /dev/tty1; and not set -q WAYLAND_DISPLAY; and not set -q ARDAOS_NO_SESSION
    /usr/lib/ardaos/arda-session
    or echo "⚠ the graphical session failed — you're in the plain console. Try: arda doctor"
end

status is-interactive; or return

# home screen: Şemistan + hints
function fish_greeting
    command -q fastfetch; and fastfetch
    set_color $fish_color_autosuggestion
    echo "  go · web · music · files · lg · sys · arda help"
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
command -q atuin; and atuin init fish --disable-up-arrow | source

# daily verbs
alias go 'arda go'
alias web 'arda go web'
alias music spotify_player
alias files yazi
alias lg lazygit
alias sys btop
alias wifi nmtui
alias vol pulsemixer
alias cheat tldr
alias home 'swaymsg workspace 1 >/dev/null'
