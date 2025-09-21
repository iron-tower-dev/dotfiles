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

# Initialize Oh My Posh if available
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init zsh --config ~/.config/catppuccin-macchiato.omp.toml)"
fi

# Initialize direnv if available
if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
fi

# Initialize zoxide if available
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# Load Angular CLI autocompletion if available (with robust error handling)
# Note: Load this after all PATH modifications are complete
load_ng_completion() {
    if command -v ng &> /dev/null 2>&1; then
        local ng_completion
        ng_completion=$(ng completion script 2>/dev/null)
        if [[ $? -eq 0 && -n "$ng_completion" ]]; then
            eval "$ng_completion" 2>/dev/null || true
        fi
    fi
}

# Defer Angular CLI completion loading until after shell is fully initialized
autoload -U add-zsh-hook
add-zsh-hook precmd load_ng_completion_once
load_ng_completion_once() {
    load_ng_completion
    add-zsh-hook -d precmd load_ng_completion_once
}
