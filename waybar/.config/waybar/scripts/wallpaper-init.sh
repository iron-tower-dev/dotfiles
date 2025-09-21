#!/bin/bash

# Wallpaper Initialization Script
# Sets an initial wallpaper on system startup after swww-daemon is ready

set -euo pipefail

# Configuration
WALLPAPER_DIR="$HOME/dotfiles/wallpapers"
MAX_WAIT_TIME=30
WAIT_INTERVAL=1

# Logging function
log_info() {
    echo "[WALLPAPER-INIT] $1" >&2
}

log_error() {
    echo "[WALLPAPER-INIT ERROR] $1" >&2
}

# Wait for swww-daemon to be ready
wait_for_swww() {
    local wait_time=0
    
    log_info "Waiting for swww-daemon to be ready..."
    
    while ! swww query >/dev/null 2>&1; do
        if [ $wait_time -ge $MAX_WAIT_TIME ]; then
            log_error "swww-daemon did not become ready within $MAX_WAIT_TIME seconds"
            return 1
        fi
        
        sleep $WAIT_INTERVAL
        wait_time=$((wait_time + WAIT_INTERVAL))
    done
    
    log_info "swww-daemon is ready after ${wait_time}s"
    return 0
}

# Set initial wallpaper
set_initial_wallpaper() {
    if [[ ! -d "$WALLPAPER_DIR" ]]; then
        log_error "Wallpapers directory not found: $WALLPAPER_DIR"
        return 1
    fi
    
    # Find a nice default wallpaper (prefer catppuccin themed ones)
    local default_wallpaper=""
    
    # Try to find catppuccin themed wallpapers first
    for pattern in "catppuccin*" "*catppuccin*" "*macchiato*"; do
        local found_wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -iname "$pattern" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -1)
        if [[ -n "$found_wallpaper" ]]; then
            default_wallpaper="$found_wallpaper"
            break
        fi
    done
    
    # If no catppuccin wallpaper found, use any wallpaper
    if [[ -z "$default_wallpaper" ]]; then
        default_wallpaper=$(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | head -1)
    fi
    
    if [[ -z "$default_wallpaper" ]]; then
        log_error "No suitable wallpaper found in $WALLPAPER_DIR"
        return 1
    fi
    
    log_info "Setting initial wallpaper: $(basename "$default_wallpaper")"
    
    # Set wallpaper with a gentle fade transition
    if swww img "$default_wallpaper" --transition-type fade --transition-duration 2; then
        log_info "Initial wallpaper set successfully"
        return 0
    else
        log_error "Failed to set initial wallpaper"
        return 1
    fi
}

# Main function
main() {
    log_info "Starting wallpaper initialization..."
    
    # Wait for swww-daemon to be ready
    if ! wait_for_swww; then
        log_error "Could not initialize wallpaper system"
        exit 1
    fi
    
    # Set initial wallpaper
    if set_initial_wallpaper; then
        log_info "Wallpaper initialization completed successfully"
        exit 0
    else
        log_error "Wallpaper initialization failed"
        exit 1
    fi
}

# Run main function
main "$@"
