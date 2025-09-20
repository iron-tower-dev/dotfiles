# System Utilities for Nushell
# System monitoring, process management, and utility functions

# Enhanced process viewer with filtering
def "psg" [pattern: string] {
  ps | where name =~ $pattern or command =~ $pattern
}

# Memory usage by process
def "memtop" [--count (-n): int = 10] {
  ps | sort-by mem -r | first $count | select name pid mem cpu
}

# CPU usage by process  
def "cputop" [--count (-n): int = 10] {
  ps | sort-by cpu -r | first $count | select name pid cpu mem
}

# Disk usage with human readable sizes
def "diskinfo" [] {
  df -h | from ssv | select Filesystem Size Used Avail "Use%" "Mounted on"
}

# Show listening ports
def "ports" [] {
  netstat -tlnp 2>/dev/null | lines | skip 2 | where $it != "" | each { |line|
    let parts = ($line | split row " " | where $it != "")
    if ($parts | length) >= 4 {
      {
        proto: $parts.0
        local: $parts.3
        state: $parts.5
        process: (if ($parts | length) > 6 { $parts.6 } else { "unknown" })
      }
    }
  } | where proto != null
}

# Show network connections
def "netconns" [] {
  ss -tuln | lines | skip 1 | where $it != "" | each { |line|
    let parts = ($line | str trim | split row " " | where $it != "")
    if ($parts | length) >= 5 {
      {
        netid: $parts.0
        state: $parts.1
        recv_q: $parts.2
        send_q: $parts.3
        local_address: $parts.4
        peer_address: (if ($parts | length) > 5 { $parts.5 } else { "*" })
      }
    }
  } | where netid != null
}

# Temperature monitoring (if sensors available)
def "temps" [] {
  if (which sensors | is-not-empty) {
    sensors | lines | where $it =~ "°C" | each { |line|
      let parts = ($line | str trim | parse -r '(?P<sensor>.*?):\s+\+?(?P<temp>\d+\.\d+)°C')
      if ($parts | length) > 0 {
        {
          sensor: $parts.0.sensor
          temperature: ($parts.0.temp | into float)
          unit: "°C"
        }
      }
    } | where sensor != null
  } else {
    print "sensors command not found. Install lm-sensors package."
  }
}

# System load information
def "loadinfo" [] {
  let uptime_output = (uptime | str trim)
  let load_parts = ($uptime_output | parse -r '.*load average: (?P<load1>\d+\.\d+), (?P<load5>\d+\.\d+), (?P<load15>\d+\.\d+)')
  
  if ($load_parts | length) > 0 {
    {
      load_1min: ($load_parts.0.load1 | into float)
      load_5min: ($load_parts.0.load5 | into float)
      load_15min: ($load_parts.0.load15 | into float)
      cpu_cores: (nproc | into int)
    }
  }
}

# Find files by name pattern
def "findname" [pattern: string, path: string = "."] {
  find $path -name $pattern -type f | lines
}

# Find files by content
def "findcontent" [pattern: string, path: string = "."] {
  if (which rg | is-not-empty) {
    rg --files-with-matches $pattern $path | lines
  } else {
    grep -r -l $pattern $path | lines
  }
}

# Show file type distribution in directory
def "filetypes" [path: string = "."] {
  ls $path -a | where type == file | get name | each { |file|
    $file | path extension
  } | group-by | transpose extension count | sort-by count -r
}

# Monitor file changes (simple version)
def "watch-file" [file: string, --interval (-i): int = 1] {
  let original_time = (stat $file | get modified)
  print $"Watching ($file) for changes... (Ctrl+C to stop)"
  
  loop {
    sleep $"($interval)sec"
    let current_time = (stat $file | get modified)
    if $current_time != $original_time {
      print $"(date now | format date '%Y-%m-%d %H:%M:%S'): File ($file) changed"
      let original_time = $current_time
    }
  }
}

# Clean up disk space
def "cleanup" [] {
  print "Cleaning up system..."
  
  # Clean package cache
  if (which pacman | is-not-empty) {
    print "Cleaning pacman cache..."
    sudo pacman -Scc --noconfirm
  }
  
  # Clean user cache
  if ("~/.cache" | path exists) {
    print "Cleaning user cache..."
    let cache_size = (du ~/.cache | get apparent)
    print $"Cache size before: ($cache_size)"
    rm -rf ~/.cache/*
    let new_cache_size = (du ~/.cache | get apparent)
    print $"Cache size after: ($new_cache_size)"
  }
  
  # Clean temporary files
  if ("/tmp" | path exists) {
    print "Cleaning temporary files..."
    sudo find /tmp -type f -atime +7 -delete 2>/dev/null
  }
  
  print "Cleanup completed!"
}

# System backup utility
def "backup-system" [backup_dir: string] {
  print $"Creating system backup in ($backup_dir)..."
  mkdir $backup_dir
  
  # Backup important configs
  print "Backing up configurations..."
  cp -r ~/.config $"($backup_dir)/config"
  
  # Backup installed packages list
  print "Backing up package list..."
  pacman -Qqe | save $"($backup_dir)/packages.txt"
  
  if (which paru | is-not-empty) {
    paru -Qqem | save $"($backup_dir)/aur-packages.txt"
  }
  
  # Backup crontab
  if (which crontab | is-not-empty) {
    crontab -l | save $"($backup_dir)/crontab.txt"
  }
  
  print $"Backup completed in ($backup_dir)"
}

# Show hardware information
def "hwinfo" [] {
  print "Hardware Information:"
  print "==================="
  
  # CPU info
  if ("/proc/cpuinfo" | path exists) {
    let cpu_info = (open /proc/cpuinfo | lines | where $it =~ "model name" | first)
    if ($cpu_info | is-not-empty) {
      let cpu_model = ($cpu_info | split row ":" | get 1 | str trim)
      print $"CPU: ($cpu_model)"
    }
  }
  
  # Memory info
  if ("/proc/meminfo" | path exists) {
    let mem_total = (open /proc/meminfo | lines | where $it =~ "MemTotal" | first | split row " " | where $it != "" | get 1 | into int)
    let mem_available = (open /proc/meminfo | lines | where $it =~ "MemAvailable" | first | split row " " | where $it != "" | get 1 | into int)
    print $"Memory: (($mem_total / 1024 / 1024) | math round) GB total, (($mem_available / 1024 / 1024) | math round) GB available"
  }
  
  # GPU info (if available)
  if (which lspci | is-not-empty) {
    let gpu_info = (lspci | lines | where $it =~ "VGA")
    if ($gpu_info | length) > 0 {
      print $"GPU: (($gpu_info | first) | split row ': ' | get 1)"
    }
  }
  
  # Disk info
  print "Disk Usage:"
  df -h | from ssv | select Filesystem Size Used Avail "Use%" "Mounted on" | where "Mounted on" == "/"
}

# Network speed test (simple)
def "speedtest" [] {
  if (which curl | is-not-empty) {
    print "Testing internet connection speed..."
    print "Download test:"
    curl -o /dev/null -w "Downloaded at %{speed_download} bytes/sec\n" -s http://speedtest.wdc01.softlayer.com/downloads/test10.zip
    
    print "Upload test (approximate):"
    curl -o /dev/null -w "Upload speed: %{speed_upload} bytes/sec\n" -s -F "file=@/dev/zero" http://httpbin.org/post
  } else {
    print "curl not found. Please install curl to run speed test."
  }
}

# Monitor system resources
def "sysmon" [--interval (-i): int = 2] {
  print "System Monitor (Ctrl+C to stop)"
  print "=============================="
  
  loop {
    clear
    print $"(date now | format date '%Y-%m-%d %H:%M:%S')"
    print ""
    
    # Load average
    let load = (loadinfo)
    print $"Load: ($load.load_1min) ($load.load_5min) ($load.load_15min)"
    
    # Memory usage
    let mem_info = (free | lines | get 1 | split row " " | where $it != "")
    let mem_used = ($mem_info | get 2 | into int)
    let mem_total = ($mem_info | get 1 | into int)
    let mem_percent = (($mem_used * 100) / $mem_total | math round)
    print $"Memory: ($mem_percent)% used"
    
    # Top processes by CPU
    print ""
    print "Top CPU processes:"
    ps | sort-by cpu -r | first 5 | select name pid cpu | table
    
    sleep $"($interval)sec"
  }
}

print $"(ansi cyan)System utilities loaded!(ansi reset)"
