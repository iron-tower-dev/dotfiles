# Development utility functions for Fish shell

# Function to start a simple HTTP server
function serve
    set port 8000
    if test (count $argv) -eq 1
        set port $argv[1]
    end
    
    if command -v python3 >/dev/null 2>&1
        echo "Starting HTTP server on port $port..."
        python3 -m http.server $port
    else if command -v python >/dev/null 2>&1
        echo "Starting HTTP server on port $port..."
        python -m SimpleHTTPServer $port
    else
        echo "Python not found. Cannot start HTTP server."
        return 1
    end
end

# Function to find and kill process by name
function killp
    if test (count $argv) -eq 1
        set pids (pgrep -f $argv[1])
        if test -n "$pids"
            echo "Found processes matching '$argv[1]':"
            ps aux | grep $argv[1] | grep -v grep
            echo "PIDs: $pids"
            read -P "Kill these processes? (y/N): " -n 1 confirm
            if test "$confirm" = "y" -o "$confirm" = "Y"
                kill $pids
                echo "Processes killed"
            else
                echo "Aborted"
            end
        else
            echo "No processes found matching '$argv[1]'"
        end
    else
        echo "Usage: killp <process_name>"
        return 1
    end
end

# Function to show disk usage of directories
function duf
    if test (count $argv) -eq 0
        du -sh */ 2>/dev/null | sort -hr
    else
        du -sh $argv 2>/dev/null | sort -hr
    end
end

# Function to find large files
function bigfiles
    set size "100M"
    set path "."
    
    if test (count $argv) -eq 1
        set size $argv[1]
    else if test (count $argv) -eq 2
        set size $argv[1]
        set path $argv[2]
    end
    
    find $path -type f -size +$size -exec ls -lh {} \; 2>/dev/null | awk '{ print $NF ": " $5 }' | sort -k2 -hr
end

# Function to create a backup of a file/directory with timestamp
function bak
    if test (count $argv) -eq 1
        set timestamp (date +%Y%m%d_%H%M%S)
        cp -r $argv[1] "$argv[1].bak_$timestamp"
        echo "Backup created: $argv[1].bak_$timestamp"
    else
        echo "Usage: bak <file_or_directory>"
        return 1
    end
end

# Function to extract various archive formats
function unpack
    if test (count $argv) -eq 1
        switch $argv[1]
            case "*.tar.bz2"
                tar xjf $argv[1]
            case "*.tar.gz"
                tar xzf $argv[1]
            case "*.bz2"
                bunzip2 $argv[1]
            case "*.rar"
                unrar x $argv[1]
            case "*.gz"
                gunzip $argv[1]
            case "*.tar"
                tar xf $argv[1]
            case "*.tbz2"
                tar xjf $argv[1]
            case "*.tgz"
                tar xzf $argv[1]
            case "*.zip"
                unzip $argv[1]
            case "*.Z"
                uncompress $argv[1]
            case "*.7z"
                7z x $argv[1]
            case "*.xz"
                unxz $argv[1]
            case "*.exe"
                cabextract $argv[1]
            case "*"
                echo "'$argv[1]' - unknown archive method"
                return 1
        end
    else
        echo "Usage: unpack <archive_file>"
        return 1
    end
end

# Function to show system information
function sysinfo
    echo "System Information:"
    echo "=================="
    echo "Hostname: "(hostname)
    echo "OS: "(uname -o)
    echo "Kernel: "(uname -r)
    echo "Architecture: "(uname -m)
    echo "Uptime: "(uptime -p)
    echo "Shell: "$SHELL
    echo "Terminal: "$TERM
    
    if test -f /etc/os-release
        echo "Distribution: "(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
    end
    
    echo ""
    echo "Hardware Information:"
    echo "==================="
    echo "CPU: "(lscpu | grep "Model name" | cut -d: -f2 | xargs)
    echo "Memory: "(free -h | grep "^Mem:" | awk '{print $3 "/" $2}')
    echo "Disk Usage: "(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')
end

# Function to show network information
function netinfo
    echo "Network Information:"
    echo "=================="
    echo "Internal IP: "(hostname -I | awk '{print $1}')
    echo "External IP: "(curl -s ifconfig.me 2>/dev/null || echo "Unable to fetch")
    echo "DNS Servers: "(grep nameserver /etc/resolv.conf | awk '{print $2}' | tr '\n' ' ')
    echo ""
    echo "Active Network Interfaces:"
    ip addr show | grep -E "^[0-9]|inet " | grep -v "127.0.0.1"
end
