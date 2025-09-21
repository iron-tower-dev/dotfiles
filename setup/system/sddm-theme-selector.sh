#!/bin/bash

# SDDM Catppuccin Theme Selector
# Allows switching between different Catppuccin Macchiato color variants

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Available Catppuccin Macchiato color variants
VARIANTS=(
    "blue"
    "flamingo"
    "green"
    "lavender"
    "maroon"
    "mauve"
    "peach"
    "pink"
    "red"
    "rosewater"
    "sapphire"
    "sky"
    "teal"
    "yellow"
)

# Display available themes
show_variants() {
    log_info "Available Catppuccin Macchiato variants:"
    echo
    
    for i in "${!VARIANTS[@]}"; do
        local num=$((i + 1))
        local variant="${VARIANTS[i]}"
        local theme_path="/usr/share/sddm/themes/catppuccin-macchiato-${variant}"
        
        if [[ -d "$theme_path" ]]; then
            echo "  $num) ${variant^} (✓ installed)"
        else
            echo "  $num) ${variant^} (✗ not installed)"
        fi
    done
    
    echo
}

# Get current theme
get_current_theme() {
    if [[ -f "/etc/sddm.conf" ]]; then
        grep "^Current=" /etc/sddm.conf | cut -d'=' -f2 || echo "unknown"
    else
        echo "no-config"
    fi
}

# Set theme variant
set_theme_variant() {
    local variant="$1"
    local theme_name="catppuccin-macchiato-${variant}"
    local theme_path="/usr/share/sddm/themes/${theme_name}"
    
    # Check if theme exists
    if [[ ! -d "$theme_path" ]]; then
        log_error "Theme variant '${variant}' is not installed"
        log_info "Install it with: paru -S catppuccin-sddm-theme-macchiato"
        return 1
    fi
    
    # Update dotfiles configuration
    log_info "Updating dotfiles configuration..."
    sed -i "s/^Current=.*/Current=${theme_name}/" "${DOTFILES_DIR}/sddm/sddm.conf"
    
    # Update system configuration
    log_info "Updating system configuration..."
    sudo sed -i "s/^Current=.*/Current=${theme_name}/" /etc/sddm.conf
    
    log_success "SDDM theme changed to: ${theme_name}"
    log_info "Changes will take effect after restarting SDDM or rebooting"
}

# Preview theme colors
preview_variant() {
    local variant="$1"
    
    case "$variant" in
        "blue")
            echo -e "Preview: ${BLUE}■■■■■${NC} Blue accent - Classic, professional"
            ;;
        "flamingo") 
            echo -e "Preview: \033[38;5;217m■■■■■${NC} Flamingo accent - Soft pink-orange"
            ;;
        "green")
            echo -e "Preview: \033[0;32m■■■■■${NC} Green accent - Natural, calming"
            ;;
        "lavender")
            echo -e "Preview: \033[38;5;183m■■■■■${NC} Lavender accent - Light purple"
            ;;
        "maroon")
            echo -e "Preview: \033[38;5;124m■■■■■${NC} Maroon accent - Deep red"
            ;;
        "mauve")
            echo -e "Preview: \033[38;5;176m■■■■■${NC} Mauve accent - Purple-pink"
            ;;
        "peach")
            echo -e "Preview: \033[38;5;216m■■■■■${NC} Peach accent - Warm orange"
            ;;
        "pink")
            echo -e "Preview: \033[38;5;218m■■■■■${NC} Pink accent - Vibrant pink"
            ;;
        "red")
            echo -e "Preview: ${RED}■■■■■${NC} Red accent - Bold, energetic"
            ;;
        "rosewater")
            echo -e "Preview: \033[38;5;224m■■■■■${NC} Rosewater accent - Subtle pink"
            ;;
        "sapphire")
            echo -e "Preview: \033[38;5;33m■■■■■${NC} Sapphire accent - Bright blue"
            ;;
        "sky")
            echo -e "Preview: \033[38;5;117m■■■■■${NC} Sky accent - Light blue"
            ;;
        "teal")
            echo -e "Preview: \033[38;5;6m■■■■■${NC} Teal accent - Blue-green"
            ;;
        "yellow")
            echo -e "Preview: ${YELLOW}■■■■■${NC} Yellow accent - Bright, cheerful"
            ;;
        *)
            echo "Preview not available for: $variant"
            ;;
    esac
}

# Interactive selection
interactive_selection() {
    local current_theme=$(get_current_theme)
    
    log_info "Current SDDM theme: $current_theme"
    echo
    
    show_variants
    
    echo "  0) Exit without changing"
    echo
    
    read -p "Select theme variant (0-${#VARIANTS[@]}): " choice
    
    if [[ "$choice" == "0" ]]; then
        log_info "No changes made"
        exit 0
    fi
    
    if [[ "$choice" =~ ^[1-9][0-9]*$ ]] && [ "$choice" -le "${#VARIANTS[@]}" ]; then
        local variant_index=$((choice - 1))
        local selected_variant="${VARIANTS[variant_index]}"
        
        echo
        preview_variant "$selected_variant"
        echo
        
        read -p "Apply theme variant '${selected_variant}'? [y/N]: " confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            set_theme_variant "$selected_variant"
        else
            log_info "Theme change cancelled"
        fi
    else
        log_error "Invalid selection: $choice"
        exit 1
    fi
}

# Main function
main() {
    case "${1:-}" in
        "--list")
            show_variants
            ;;
        "--current")
            local current_theme=$(get_current_theme)
            echo "Current theme: $current_theme"
            ;;
        "--set")
            if [[ -n "${2:-}" ]]; then
                set_theme_variant "$2"
            else
                log_error "Please specify a variant name"
                echo "Usage: $0 --set <variant>"
                exit 1
            fi
            ;;
        "--help")
            echo "SDDM Catppuccin Theme Selector"
            echo
            echo "Usage:"
            echo "  $0                Interactive theme selection"
            echo "  $0 --list         List available variants"
            echo "  $0 --current      Show current theme"
            echo "  $0 --set VARIANT  Set specific variant"
            echo "  $0 --help         Show this help"
            echo
            echo "Available variants: ${VARIANTS[*]}"
            ;;
        "")
            interactive_selection
            ;;
        *)
            log_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
