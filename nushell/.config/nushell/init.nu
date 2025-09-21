# Nushell Development Tools Initialization
# Run this script to set up zoxide, direnv, and mise integration
# Usage: source ~/.config/nushell/init.nu

print "Initializing Nushell development tools..."

# Initialize zoxide if available  
if (which zoxide | is-not-empty) {
  print "Setting up zoxide..."
  let zoxide_config = $"($env.HOME)/.config/nushell/zoxide.nu"
  ^zoxide init nushell | save --force $zoxide_config
  print $"Zoxide configuration saved to ($zoxide_config)"
  print "To use zoxide, restart Nushell or run: source ~/.config/nushell/zoxide.nu"
}

# Initialize direnv if available
if (which direnv | is-not-empty) {
  print "Setting up direnv..."
  let direnv_config = $"($env.HOME)/.config/nushell/direnv.nu"
  ^direnv hook nushell | save --force $direnv_config
  print $"Direnv configuration saved to ($direnv_config)"
  print "To use direnv, restart Nushell or run: source ~/.config/nushell/direnv.nu"
}

# Initialize mise if available
if (which mise | is-not-empty) {
  print "Setting up mise..."
  let mise_config = $"($env.HOME)/.config/nushell/mise.nu"
  ^mise activate nu | save --force $mise_config
  print $"Mise configuration saved to ($mise_config)"
  print "To use mise, restart Nushell or run: source ~/.config/nushell/mise.nu"
}

print ""
print $"(ansi green)Development tools initialization complete!(ansi reset)"
print $"(ansi yellow)Restart Nushell to activate all integrations.(ansi reset)"
