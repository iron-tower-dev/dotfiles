#!/bin/bash

# GE-Proton Management Script
# Downloads and installs the latest Proton-GE builds for Steam

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[GE-PROTON]${NC} $1"; }
log_success() { echo -e "${GREEN}[GE-PROTON]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[GE-PROTON]${NC} $1"; }
log_error() { echo -e "${RED}[GE-PROTON]${NC} $1"; }

# Configuration
STEAM_COMPAT_DIR="$HOME/.steam/root/compatibilitytools.d"
PROTON_GE_API_URL="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
TEMP_DIR="/tmp/proton-ge-install"

# Ensure required directories exist
setup_directories() {
    log_info "Setting up directories..."
    
    mkdir -p "$STEAM_COMPAT_DIR"
    mkdir -p "$TEMP_DIR"
    
    log_success "Directories created"
}

# Check if Steam is installed
check_steam() {
    log_info "Checking Steam installation..."
    
    if ! command -v steam >/dev/null 2>&1; then
        log_error "Steam is not installed. Please install Steam first using the gaming setup script."
        exit 1
    fi
    
    # Check if Steam has been run at least once
    if [[ ! -d "$HOME/.steam" ]]; then
        log_warning "Steam hasn't been run yet. Please launch Steam once and then run this script again."
        log_info "You can launch Steam with: steam"
        exit 1
    fi
    
    log_success "Steam installation found"
}

# Get latest GE-Proton version info
get_latest_version() {
    log_info "Fetching latest GE-Proton version information..." >&2
    
    # Check if jq is available for better JSON parsing
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is required for JSON parsing. Please install it: sudo pacman -S jq" >&2
        exit 1
    fi
    
    # Get all releases and find the first one with assets
    local releases_response
    if ! releases_response=$(curl -s "https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases"); then
        log_error "Failed to fetch releases from GitHub API" >&2
        exit 1
    fi
    
    # Find the latest release that has a tar.gz asset
    local release_info
    release_info=$(echo "$releases_response" | jq -r '.[] | select(.assets | length > 0) | select(.assets[].name | contains(".tar.gz")) | "\(.tag_name) \(.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url)"' | head -1)
    
    if [[ -z "$release_info" ]]; then
        log_error "No GE-Proton release with downloadable assets found" >&2
        exit 1
    fi
    
    echo "$release_info"
}

# Check if version is already installed
is_version_installed() {
    local version="$1"
    [[ -d "$STEAM_COMPAT_DIR/$version" ]]
}

# List installed GE-Proton versions
list_installed_versions() {
    log_info "Installed GE-Proton versions:"
    
    if [[ -d "$STEAM_COMPAT_DIR" ]]; then
        local count=0
        for dir in "$STEAM_COMPAT_DIR"/GE-Proton*; do
            if [[ -d "$dir" ]]; then
                local version
                version=$(basename "$dir")
                echo "  - $version"
                ((count++))
            fi
        done
        
        if [[ $count -eq 0 ]]; then
            log_warning "No GE-Proton versions installed"
        fi
    else
        log_warning "No GE-Proton versions installed"
    fi
}

# Download and install GE-Proton
install_ge_proton() {
    local version="$1"
    local download_url="$2"
    
    log_info "Installing GE-Proton $version..."
    
    # Check if already installed
    if is_version_installed "$version"; then
        log_warning "GE-Proton $version is already installed"
        return 0
    fi
    
    # Clean temp directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Download
    log_info "Downloading GE-Proton $version..."
    local archive_path="$TEMP_DIR/$(basename "$download_url")"
    
    if ! curl -L -o "$archive_path" "$download_url" --progress-bar; then
        log_error "Failed to download GE-Proton $version"
        exit 1
    fi
    
    # Extract
    log_info "Extracting GE-Proton $version..."
    cd "$TEMP_DIR"
    
    if ! tar -xzf "$archive_path"; then
        log_error "Failed to extract GE-Proton archive"
        exit 1
    fi
    
    # Move to Steam compatibility directory
    local extracted_dir
    extracted_dir=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "GE-Proton*" | head -1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Failed to find extracted GE-Proton directory"
        exit 1
    fi
    
    mv "$extracted_dir" "$STEAM_COMPAT_DIR/"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    log_success "GE-Proton $version installed successfully"
}

# Remove old GE-Proton versions (keep latest 3)
cleanup_old_versions() {
    log_info "Cleaning up old GE-Proton versions (keeping latest 3)..."
    
    local versions=()
    for dir in "$STEAM_COMPAT_DIR"/GE-Proton*; do
        if [[ -d "$dir" ]]; then
            versions+=($(basename "$dir"))
        fi
    done
    
    if [[ ${#versions[@]} -le 3 ]]; then
        log_info "Only ${#versions[@]} versions installed, no cleanup needed"
        return 0
    fi
    
    # Sort versions by modification time (newest first)
    local sorted_versions=()
    while IFS= read -r -d '' version; do
        sorted_versions+=($(basename "$version"))
    done < <(find "$STEAM_COMPAT_DIR" -maxdepth 1 -type d -name "GE-Proton*" -printf '%T@ %p\0' | sort -rn -z | cut -d' ' -f2- -z)
    
    # Remove versions beyond the first 3
    local removed_count=0
    for ((i=3; i<${#sorted_versions[@]}; i++)); do
        local version_to_remove="${sorted_versions[i]}"
        log_info "Removing old version: $version_to_remove"
        rm -rf "$STEAM_COMPAT_DIR/$version_to_remove"
        ((removed_count++))
    done
    
    if [[ $removed_count -gt 0 ]]; then
        log_success "Removed $removed_count old versions"
    else
        log_info "No old versions to remove"
    fi
}

# Update GE-Proton (install latest if not already installed)
update_ge_proton() {
    log_info "Checking for GE-Proton updates..."
    
    local version_info
    version_info=$(get_latest_version)
    
    # Parse the version and URL
    local latest_version
    local download_url
    latest_version=$(echo "$version_info" | cut -d' ' -f1)
    download_url=$(echo "$version_info" | cut -d' ' -f2-)
    
    log_info "Latest GE-Proton version: $latest_version"
    log_info "Download URL: $download_url"
    
    if is_version_installed "$latest_version"; then
        log_success "Latest version $latest_version is already installed"
    else
        install_ge_proton "$latest_version" "$download_url"
        cleanup_old_versions
        log_success "GE-Proton updated to $latest_version"
    fi
}

# Remove specific GE-Proton version
remove_version() {
    local version="$1"
    
    if [[ -z "$version" ]]; then
        log_error "No version specified for removal"
        exit 1
    fi
    
    if ! is_version_installed "$version"; then
        log_warning "GE-Proton $version is not installed"
        return 0
    fi
    
    log_info "Removing GE-Proton $version..."
    rm -rf "$STEAM_COMPAT_DIR/$version"
    log_success "GE-Proton $version removed"
}

# Show Steam instructions
show_steam_instructions() {
    log_info "To use GE-Proton in Steam:"
    echo "1. Restart Steam if it's currently running"
    echo "2. Right-click on a Windows game in your Steam library"
    echo "3. Go to Properties -> Compatibility"
    echo "4. Check 'Force the use of a specific Steam Play compatibility tool'"
    echo "5. Select the GE-Proton version from the dropdown"
    echo ""
    log_info "For global settings:"
    echo "1. Go to Steam -> Settings -> Steam Play"
    echo "2. Check 'Enable Steam Play for supported titles'"
    echo "3. Check 'Enable Steam Play for all other titles'"
    echo "4. Select GE-Proton from the dropdown"
}

# Display help
show_help() {
    echo "GE-Proton Management Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  install, update    Install/update to the latest GE-Proton version"
    echo "  list              List installed GE-Proton versions"
    echo "  remove VERSION    Remove a specific GE-Proton version"
    echo "  cleanup           Remove old versions (keep latest 3)"
    echo "  instructions      Show Steam usage instructions"
    echo "  help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 install                    # Install latest GE-Proton"
    echo "  $0 list                       # List installed versions"
    echo "  $0 remove GE-Proton8-26      # Remove specific version"
    echo "  $0 cleanup                    # Clean up old versions"
}

# Main function
main() {
    local action="${1:-install}"
    
    case "$action" in
        "install"|"update")
            check_steam
            setup_directories
            update_ge_proton
            show_steam_instructions
            ;;
        "list")
            list_installed_versions
            ;;
        "remove")
            local version="${2:-}"
            remove_version "$version"
            ;;
        "cleanup")
            cleanup_old_versions
            ;;
        "instructions")
            show_steam_instructions
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown action: $action"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
