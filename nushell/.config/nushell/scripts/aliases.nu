# Nushell Aliases and Custom Commands
# Modern command replacements and useful shortcuts

# Modern command replacements (if available)
def setup_modern_commands [] {
  # exa/eza as ls replacement
  if (which exa | is-not-empty) {
    alias ls = exa --icons --group-directories-first
    alias ll = exa -l --icons --group-directories-first --git
    alias la = exa -la --icons --group-directories-first --git  
    alias tree = exa --tree --icons
  } else if (which eza | is-not-empty) {
    alias ls = eza --icons --group-directories-first
    alias ll = eza -l --icons --group-directories-first --git
    alias la = eza -la --icons --group-directories-first --git
    alias tree = eza --tree --icons
  }

  # bat as cat replacement
  if (which bat | is-not-empty) {
    alias cat = bat
  }

  # fd as find replacement
  if (which fd | is-not-empty) {
    alias find = fd
  }

  # ripgrep as grep replacement
  if (which rg | is-not-empty) {
    alias grep = rg
  }

  # btop as htop/top replacement
  if (which btop | is-not-empty) {
    alias htop = btop
    alias top = btop
  }

  # delta as diff replacement
  if (which delta | is-not-empty) {
    alias diff = delta
  }
}

# Git aliases
alias g = git
alias ga = git add
alias gaa = git add .
alias gc = git commit
alias gcm = git commit -m
alias gca = git commit -am
alias gp = git push
alias gpl = git pull
alias gs = git status
alias gd = git diff
alias gl = git log --oneline --graph --decorate
alias gb = git branch
alias gco = git checkout

# System aliases
alias c = clear
alias h = history
alias j = jobs
alias q = exit
# Custom reload function (avoids circular import by not reloading full config)
def "reload" [] {
  print "Note: Use 'exit' and start nu again to fully reload configuration"
  print "Or manually source specific files as needed"
}

# Navigation aliases
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias ~ = cd ~

# Package management aliases (Arch Linux)
alias pacs = sudo pacman -S        # Install packages
alias pacu = sudo pacman -Syu      # Update system
alias pacr = sudo pacman -R        # Remove package
alias pacss = pacman -Ss           # Search packages
alias pacsi = pacman -Si           # Package info
alias paclo = pacman -Qdt          # List orphans
alias pacc = sudo pacman -Scc      # Clear cache
alias paclf = pacman -Ql           # List files

# AUR helper aliases (if paru is installed)
def setup_aur_aliases [] {
  if (which paru | is-not-empty) {
    alias yay = paru
    alias yays = paru -S
    alias yayu = paru -Syu
    alias yayss = paru -Ss
  }
}

# Docker aliases (if docker is installed)
def setup_docker_aliases [] {
  if (which docker | is-not-empty) {
    alias dk = docker
    alias dkps = docker ps
    alias dkpsa = docker ps -a
    alias dki = docker images
    alias dkrm = docker rm
    alias dkrmi = docker rmi
    alias dke = docker exec -it
    alias dkl = docker logs
    alias dkc = docker-compose
    alias dkcu = docker-compose up
    alias dkcd = docker-compose down
  }
}

# System information aliases
alias sysinfo = fastfetch
alias weather = curl wttr.in
alias myip = curl ipinfo.io/ip

# File operations with safety
alias cp = cp -i
alias mv = mv -i
alias rm = rm -i

# Quick edit configs (using functions instead of aliases for expressions)
def "nushellconfig" [] {
  ^$env.EDITOR ~/.config/nushell/config.nu
}

def "fishconfig" [] {
  ^$env.EDITOR ~/.config/fish/config.fish
}

def "hyprconfig" [] {
  ^$env.EDITOR ~/.config/hypr/hyprland.conf
}

def "waybarconfig" [] {
  ^$env.EDITOR ~/.config/waybar/config
}

def "nvimconfig" [] {
  ^$env.EDITOR ~/.config/nvim/init.lua
}

def "miseconfig" [] {
  ^$env.EDITOR ~/.config/mise/config.toml
}

# Mise aliases
alias mls = mise ls           # List installed tools
alias mis = mise install      # Install tools  
alias muse = mise use         # Use specific version in current directory
alias mglobal = mise use -g   # Set global version
alias mwhich = mise which     # Show which version is being used
alias mup = mise upgrade      # Update all tools
alias mprune = mise prune     # Clean old versions

# Nushell-specific useful commands
def "mkcd" [path: string] {
  mkdir $path
  cd $path
}

def "backup" [file: string] {
  let backup_name = $"($file).bak"
  cp $file $backup_name
  print $"Backed up ($file) to ($backup_name)"
}

def "extract" [file: string] {
  let extension = ($file | path parse | get extension)
  match $extension {
    "zip" => { ^unzip $file }
    "tar" => { ^tar -xf $file }
    "gz" => { 
      if ($file | str ends-with ".tar.gz") {
        ^tar -xzf $file
      } else {
        ^gunzip $file
      }
    }
    "bz2" => {
      if ($file | str ends-with ".tar.bz2") {
        ^tar -xjf $file
      } else {
        ^bunzip2 $file
      }
    }
    "xz" => {
      if ($file | str ends-with ".tar.xz") {
        ^tar -xJf $file
      } else {
        ^unxz $file
      }
    }
    "7z" => { ^7z x $file }
    "rar" => { ^unrar x $file }
    _ => { print $"Unknown archive format: ($file)" }
  }
}

# Show directory sizes
def "duf" [path = "."] {
  ls $path | where type == dir | insert size { |it| ^du -s $it.name | lines | first | split column "\t" size name | get size | first } | sort-by size -r | select name size
}

# Find large files
def "bigfiles" [size = "100MB", path = "."] {
  ^find $path -type f -size +$size | lines | each { |file|
    {
      name: $file
      size: (try { ls $file | get size | first } catch { "unknown" })
    }
  } | sort-by size -r
}

# Process management
def "killp" [name: string] {
  let pids = (ps | where name =~ $name | get pid)
  if ($pids | is-empty) {
    print $"No processes found matching '($name)'"
  } else {
    print $"Found processes: ($pids)"
    let confirm = (input $"Kill these processes? (y/N): ")
    if ($confirm | str downcase) == "y" {
      $pids | each { |pid| ^kill $pid }
      print "Processes killed"
    } else {
      print "Aborted"
    }
  }
}

# Network information
def "netinfo" [] {
  print "Network Information:"
  print "=================="
  print $"Internal IP: (^hostname -I | str trim)"
  print $"External IP: (http get ifconfig.me)"
  print ""
  print "Active Network Interfaces:"
  ^ip addr show | lines | where $it =~ "inet " | each { |line| print $line }
}

# System information
def "sysinfo-detailed" [] {
  print "System Information:"
  print "=================="
  print $"Hostname: (^hostname)"
  print $"OS: (^uname -o)"
  print $"Kernel: (^uname -r)"
  print $"Architecture: (^uname -m)"
  print $"Uptime: (^uptime -p)"
  print $"Shell: ($env.SHELL? | default 'nushell')"
  print $"Terminal: ($env.TERM? | default 'unknown')"
  
  if ("/etc/os-release" | path exists) {
    let os_info = (open /etc/os-release | from ssv -n)
    print $"Distribution: (($os_info | where column1 == 'PRETTY_NAME' | get column2).0)"
  }
  
  print ""
  print "Hardware Information:"
  print "==================="
  print $"Memory: (^free -h | lines | get 1 | split row ' ' | where $it != '' | get 2)/((^free -h | lines | get 1 | split row ' ' | where $it != '' | get 1))"
  print $"Disk Usage: (^df -h / | lines | get 1 | split row ' ' | where $it != '' | get 2)/((^df -h / | lines | get 1 | split row ' ' | where $it != '' | get 1)) (((^df -h / | lines | get 1 | split row ' ' | where $it != '' | get 4)))"
}

# Start HTTP server  
def "serve" [port = 8000] {
  if (which python3 | is-not-empty) {
    print $"Starting HTTP server on port ($port)..."
    ^python3 -m http.server $port
  } else if (which python | is-not-empty) {
    print $"Starting HTTP server on port ($port)..."
    ^python -m SimpleHTTPServer $port
  } else {
    print "Python not found. Cannot start HTTP server."
  }
}

# Initialize all aliases
setup_modern_commands
setup_aur_aliases  
setup_docker_aliases

print $"(ansi green)Nushell aliases loaded!(ansi reset)"
