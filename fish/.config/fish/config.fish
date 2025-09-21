# Fish Shell Configuration
# Modern Fish setup with Catppuccin Macchiato theming

# Remove welcome message
set -U fish_greeting

# Set default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# XDG Base Directory Specification
set -gx XDG_CONFIG_HOME ~/.config
set -gx XDG_DATA_HOME ~/.local/share
set -gx XDG_CACHE_HOME ~/.cache
set -gx XDG_STATE_HOME ~/.local/state

# Path modifications (only add if not already present)
if not contains ~/.local/bin $fish_user_paths
    fish_add_path ~/.local/bin
end
if not contains ~/.cargo/bin $fish_user_paths
    fish_add_path ~/.cargo/bin
end
if not contains ~/bin $fish_user_paths; and test -d ~/bin
    fish_add_path ~/bin
end

# Wayland/Hyprland environment variables
set -gx XDG_CURRENT_DESKTOP Hyprland
set -gx XDG_SESSION_TYPE wayland
set -gx XDG_SESSION_DESKTOP Hyprland
set -gx GDK_BACKEND wayland,x11
# set -gx QT_QPA_PLATFORM wayland;xcb
set -gx SDL_VIDEODRIVER wayland
set -gx CLUTTER_BACKEND wayland
set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1

# Theme environment variables
set -gx QT_QPA_PLATFORMTHEME qt5ct
set -gx QT_QPA_PLATFORMTHEME_QT6 qt6ct
set -gx QT_STYLE_OVERRIDE kvantum
set -gx GTK_THEME catppuccin-macchiato-mauve-standard+default
set -gx XCURSOR_THEME catppuccin-macchiato-mauve-cursors
set -gx XCURSOR_SIZE 24

# Development environment
set -gx RUSTUP_HOME ~/.rustup
set -gx CARGO_HOME ~/.cargo

# Modern command replacements
if command -v exa >/dev/null 2>&1
    alias ls='exa --icons'
    alias ll='exa -l --icons --git'
    alias la='exa -la --icons --git'
    alias tree='exa --tree --icons'
end

if command -v bat >/dev/null 2>&1
    alias cat='bat'
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
end

if command -v fd >/dev/null 2>&1
    alias find='fd'
end

if command -v rg >/dev/null 2>&1
    alias grep='rg'
end

if command -v btop >/dev/null 2>&1
    alias htop='btop'
    alias top='btop'
end

# Git aliases
alias g='git'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gb='git branch'
alias gco='git checkout'

# System aliases (only define if exa is not available)
if not command -v exa >/dev/null 2>&1
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
end
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias h='history'
alias j='jobs -l'
alias q='exit'

# Package management aliases (Arch Linux)
alias pacman='sudo pacman'
alias pacs='sudo pacman -S'        # Install packages
alias pacu='sudo pacman -Syu'      # Update system
alias pacr='sudo pacman -R'        # Remove package
alias pacss='pacman -Ss'           # Search packages
alias pacsi='pacman -Si'           # Package info
alias paclo='pacman -Qdt'          # List orphans
alias pacc='sudo pacman -Scc'      # Clear cache
alias paclf='pacman -Ql'           # List files

# AUR helper aliases (if paru is installed)
if command -v paru >/dev/null 2>&1
    alias yay='paru'
    alias yays='paru -S'
    alias yayu='paru -Syu'
    alias yayss='paru -Ss'
end

# Docker aliases (if docker is installed)
if command -v docker >/dev/null 2>&1
    alias dk='docker'
    alias dkps='docker ps'
    alias dkpsa='docker ps -a'
    alias dki='docker images'
    alias dkrm='docker rm'
    alias dkrmi='docker rmi'
    alias dke='docker exec -it'
    alias dkl='docker logs'
    alias dkc='docker-compose'
    alias dkcu='docker-compose up'
    alias dkcd='docker-compose down'
end

# System information
alias sysinfo='fastfetch'
alias weather='curl wttr.in'
alias myip='curl ipinfo.io/ip'

# Quick edit configs
alias fishconfig='nvim ~/.config/fish/config.fish'
alias hyprconfig='nvim ~/.config/hypr/hyprland.conf'
alias waybarconfig='nvim ~/.config/waybar/config'
alias nvimconfig='nvim ~/.config/nvim/init.lua'
alias miseconfig='nvim ~/.config/mise/config.toml'

# Mise aliases
alias mls='mise ls'          # List installed tools
alias mis='mise install'     # Install tools
alias muse='mise use'        # Use specific version in current directory
alias mglobal='mise use -g'  # Set global version
alias mwhich='mise which'    # Show which version is being used
alias mup='mise upgrade'     # Update all tools
alias mprune='mise prune'    # Clean old versions

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Directory navigation functions
function mkcd
    mkdir -p $argv && cd $argv
end

function backup
    if test (count $argv) -eq 1
        cp $argv[1] $argv[1].bak
        echo "Backed up $argv[1] to $argv[1].bak"
    else
        echo "Usage: backup <file>"
    end
end

function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                unrar x $argv[1]
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Load Starship prompt if available
if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# Load direnv if available
if command -v direnv >/dev/null 2>&1
    direnv hook fish | source
end

# Initialize mise if available
if command -v mise >/dev/null 2>&1
    mise activate fish | source
end

# Initialize fish vi mode (optional, comment out if you prefer emacs mode)
# fish_vi_key_bindings

# Source any additional config files (skip if they exit for non-interactive shells)
if status is-interactive
    for file in ~/.config/fish/conf.d/*.fish
        if test -r $file
            source $file
        end
    end
else
    # Load only safe config files that don't exit in non-interactive mode
    for file in ~/.config/fish/conf.d/{catppuccin_theme,abbr_tips}.fish
        if test -r $file
            source $file
        end
    end
end

# uv (only add if not already present)
if not contains "$HOME/.local/bin" $fish_user_paths
    fish_add_path "$HOME/.local/bin"
end

# Auto-start SSH agent
if not pgrep -x ssh-agent > /dev/null
    eval (ssh-agent -c)
    ssh-add /home/derrick/.ssh/id_ed25519
end
