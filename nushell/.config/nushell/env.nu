# Nushell Environment Configuration
# This file is loaded before config.nu

# Default environment variables are set in config.nu
# This file is for any environment-specific setup

# Starship prompt initialization happens in config.nu
# Add any custom environment setup here if needed

# Create default directories if they don't exist
mkdir ~/.cache
mkdir ~/.local/bin
mkdir ~/.local/share

# Default PATH setup (additional paths added in config.nu)
$env.PATH = ($env.PATH | default [])

# Set default umask
umask 022

# History configuration
$env.HISTFILE = $"($env.HOME)/.config/nushell/history.txt"
