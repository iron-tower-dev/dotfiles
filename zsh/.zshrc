# ZSH Configuration with modern tools

# Initialize mise if available
if command -v mise &> /dev/null; then
    eval "$(mise activate zsh)"
fi

# Path additions
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/bin:$PATH"

# Editor settings
export EDITOR='nvim'
export VISUAL='nvim'

# Enable colors
setopt auto_cd
setopt correct
setopt share_history
setopt append_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion system
autoload -Uz compinit
compinit

# Modern command aliases
if command -v exa &> /dev/null; then
    alias ls='exa --icons --group-directories-first'
    alias ll='exa -l --icons --group-directories-first --git'
    alias la='exa -la --icons --group-directories-first --git'
    alias tree='exa --tree --icons'
fi

if command -v bat &> /dev/null; then
    alias cat='bat'
fi

if command -v btop &> /dev/null; then
    alias htop='btop'
    alias top='btop'
fi

# Git aliases
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'

# Mise aliases
alias mls='mise ls'          # List installed tools
alias mis='mise install'     # Install tools
alias muse='mise use'        # Use specific version in current directory
alias mglobal='mise use -g'  # Set global version
alias mwhich='mise which'    # Show which version is being used
alias mup='mise upgrade'     # Update all tools
alias mprune='mise prune'    # Clean old versions
alias miseconfig='$EDITOR ~/.config/mise/config.toml'

# System aliases
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Quick config edits
alias zshconfig='$EDITOR ~/.zshrc'
alias hyprconfig='$EDITOR ~/.config/hypr/hyprland.conf'

# Initialize starship if available
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# Initialize direnv if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Initialize zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Load Angular CLI autocompletion if available
if command -v ng &> /dev/null; then
    source <(ng completion script)
fi
