#!/bin/bash

# Wallpaper randomization script using swww and waypaper
# This script sets a random wallpaper from the dotfiles wallpapers directory

set -euo pipefail

# Colors for notifications
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
TRANSITION_TYPES=("simple" "fade" "wipe" "wave" "grow" "center")
TRANSITION_DURATION="1.5"
NOTIFICATION_TIMEOUT=3000

# Logging function
log_info() {
    echo -e "${BLUE}[WALLPAPER]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" >&2
}

# Check if swww daemon is running
check_swww_daemon() {
    if ! pgrep -x swww-daemon > /dev/null; then
        log_info "Starting swww daemon..."
        nohup swww-daemon >/dev/null 2>&1 &
        sleep 3
    fi
}

# Send notification if notify-send is available
send_notification() {
    local title="$1"
    local message="$2"
    local icon="$3"
    
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -t $NOTIFICATION_TIMEOUT -i "$icon" "$title" "$message"
    fi
}

# Get random wallpaper from directory
get_random_wallpaper() {
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        log_error "Wallpapers directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    # Find all image files (png, jpg, jpeg, webp)
    local wallpapers=()
    while IFS= read -r -d '' file; do
        wallpapers+=("$file")
    done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0)
    
    if [[ ${#wallpapers[@]} -eq 0 ]]; then
        log_error "No wallpaper files found in $WALLPAPER_DIR"
        return 1
    fi
    
    # Select random wallpaper
    local random_index=$((RANDOM % ${#wallpapers[@]}))
    echo "${wallpapers[$random_index]}"
}

# Get random transition type
get_random_transition() {
    local random_index=$((RANDOM % ${#TRANSITION_TYPES[@]}))
    echo "${TRANSITION_TYPES[$random_index]}"
}

# Set wallpaper using swww
set_wallpaper() {
    local wallpaper_path="$1"
    local transition_type="$2"
    
    if [[ ! -f "$wallpaper_path" ]]; then
        log_error "Wallpaper file not found: $wallpaper_path"
        return 1
    fi
    
    log_info "Setting wallpaper: $(basename "$wallpaper_path")"
    log_info "Transition: $transition_type (${TRANSITION_DURATION}s)"
    
    # Set wallpaper with swww
    if swww img "$wallpaper_path" --transition-type "$transition_type" --transition-duration "$TRANSITION_DURATION"; then
        log_success "Wallpaper set successfully"
        
        # Send notification
        local wallpaper_name=$(basename "$wallpaper_path" | sed 's/\.[^.]*$//')
        send_notification "Wallpaper Changed" "Now showing: $wallpaper_name" "preferences-desktop-wallpaper"
        
        return 0
    else
        log_error "Failed to set wallpaper"
        return 1
    fi
}

# Output JSON for Waybar (when called without arguments)
output_waybar_json() {
    local icon="󰸉"
    local text="$icon"
    local tooltip="Click to set random wallpaper"
    local class="wallpaper"
    
    # Check if swww daemon is running
    if ! pgrep -x swww-daemon > /dev/null; then
        icon="󰸉"
        class="wallpaper-inactive"
        tooltip="Wallpaper daemon not running - click to start and set wallpaper"
    fi
    
    cat << EOF
{
    "text": "$text",
    "tooltip": "$tooltip",
    "class": "$class"
}
EOF
}

# Main function
main() {
    case "${1:-}" in
        "set"|"random")
            # Set random wallpaper
            check_swww_daemon
            
            local wallpaper
            wallpaper=$(get_random_wallpaper) || exit 1
            
            local transition
            transition=$(get_random_transition)
            
            set_wallpaper "$wallpaper" "$transition"
            ;;
        "init")
            # Initialize swww daemon and set initial wallpaper
            log_info "Initializing wallpaper system..."
            check_swww_daemon
            sleep 1
            main "set"
            ;;
        "status"|"")
            # Output status for Waybar
            output_waybar_json
            ;;
        "help"|"--help")
            cat << EOF
Wallpaper Management Script

Usage:
    $0 [command]

Commands:
    set, random    Set a random wallpaper
    init          Initialize swww daemon and set initial wallpaper
    status        Output status JSON for Waybar (default)
    help          Show this help message

Examples:
    $0              # Output Waybar JSON status
    $0 set          # Set random wallpaper
    $0 init         # Initialize system
EOF
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
