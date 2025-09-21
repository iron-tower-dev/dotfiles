#!/usr/bin/env bash

# NixOS Configuration Validation Script
# Validates the flake structure and configuration files

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Validation functions
check_file_exists() {
    local file="$1"
    local description="$2"
    
    if [[ -f "$file" ]]; then
        log_success "$description exists: $file"
        return 0
    else
        log_error "$description missing: $file"
        return 1
    fi
}

check_directory_exists() {
    local dir="$1"
    local description="$2"
    
    if [[ -d "$dir" ]]; then
        log_success "$description exists: $dir"
        return 0
    else
        log_error "$description missing: $dir"
        return 1
    fi
}

validate_nix_syntax() {
    local file="$1"
    
    if command -v nix >/dev/null 2>&1; then
        if nix-instantiate --parse "$file" >/dev/null 2>&1; then
            log_success "Nix syntax valid: $file"
            return 0
        else
            log_error "Nix syntax error in: $file"
            return 1
        fi
    else
        log_warning "Nix not available, skipping syntax check for: $file"
        return 0
    fi
}

validate_flake_structure() {
    log_info "Validating flake structure..."
    
    local errors=0
    
    # Check main flake file
    if ! check_file_exists "$FLAKE_DIR/flake.nix" "Main flake file"; then
        ((errors++))
    fi
    
    # Check module directories
    if ! check_directory_exists "$FLAKE_DIR/modules" "Modules directory"; then
        ((errors++))
    fi
    
    if ! check_directory_exists "$FLAKE_DIR/hosts" "Hosts directory"; then
        ((errors++))
    fi
    
    if ! check_directory_exists "$FLAKE_DIR/users" "Users directory"; then
        ((errors++))
    fi
    
    # Check specific module files
    local module_files=(
        "modules/default.nix"
        "modules/desktop/default.nix"
        "modules/desktop/hyprland.nix"
        "modules/desktop/sddm.nix"
        "modules/desktop/waybar.nix"
        "modules/programs/default.nix"
        "modules/programs/development.nix"
        "modules/programs/shells.nix"
        "modules/themes/default.nix"
        "modules/themes/catppuccin.nix"
    )
    
    for module_file in "${module_files[@]}"; do
        if ! check_file_exists "$FLAKE_DIR/$module_file" "Module file"; then
            ((errors++))
        fi
    done
    
    # Check host configurations
    local host_configs=(
        "hosts/desktop/default.nix"
        "hosts/laptop/default.nix"
    )
    
    for host_config in "${host_configs[@]}"; do
        if ! check_file_exists "$FLAKE_DIR/$host_config" "Host configuration"; then
            ((errors++))
        fi
    done
    
    # Check user configurations
    local user_configs=(
        "users/derrick/default.nix"
        "users/derrick/desktop.nix"
        "users/derrick/programs.nix"
        "users/derrick/services.nix"
        "users/derrick/themes.nix"
    )
    
    for user_config in "${user_configs[@]}"; do
        if ! check_file_exists "$FLAKE_DIR/$user_config" "User configuration"; then
            ((errors++))
        fi
    done
    
    return $errors
}

validate_nix_files() {
    log_info "Validating Nix file syntax..."
    
    local errors=0
    
    # Find all .nix files
    local nix_files=()
    while IFS= read -r -d '' file; do
        nix_files+=("$file")
    done < <(find "$FLAKE_DIR" -name "*.nix" -type f -print0)
    
    for nix_file in "${nix_files[@]}"; do
        if ! validate_nix_syntax "$nix_file"; then
            ((errors++))
        fi
    done
    
    return $errors
}

validate_shared_resources() {
    log_info "Validating shared resources with main dotfiles..."
    
    local errors=0
    local dotfiles_root="$(dirname "$FLAKE_DIR")"
    
    # Check for shared configurations
    local shared_dirs=(
        "hyprland"
        "waybar"
        "wallpapers"
        "git"
        "neovim"
        "fish"
        "starship"
        "mise"
    )
    
    for shared_dir in "${shared_dirs[@]}"; do
        if ! check_directory_exists "$dotfiles_root/$shared_dir" "Shared resource"; then
            log_warning "Shared resource not found: $shared_dir"
        fi
    done
    
    return $errors
}

validate_scripts() {
    log_info "Validating deployment scripts..."
    
    local errors=0
    
    # Check script files
    local scripts=(
        "scripts/deploy.sh"
        "scripts/validate.sh"
    )
    
    for script in "${scripts[@]}"; do
        local script_path="$FLAKE_DIR/$script"
        if check_file_exists "$script_path" "Script"; then
            # Check if executable
            if [[ -x "$script_path" ]]; then
                log_success "Script is executable: $script"
            else
                log_warning "Script is not executable: $script"
            fi
            
            # Basic shell syntax check
            if bash -n "$script_path" 2>/dev/null; then
                log_success "Script syntax valid: $script"
            else
                log_error "Script syntax error: $script"
                ((errors++))
            fi
        else
            ((errors++))
        fi
    done
    
    return $errors
}

check_flake_inputs() {
    log_info "Checking flake inputs availability..."
    
    if command -v nix >/dev/null 2>&1; then
        cd "$FLAKE_DIR"
        
        if nix flake metadata >/dev/null 2>&1; then
            log_success "Flake metadata accessible"
            
            # Show flake info
            log_info "Flake inputs:"
            nix flake metadata --json 2>/dev/null | jq -r '.locks.nodes | to_entries[] | select(.key != "root") | "  - \(.key): \(.value.locked.rev // .value.locked.ref // "unknown")"' 2>/dev/null || echo "  (Unable to parse flake inputs)"
        else
            log_warning "Unable to access flake metadata (flake may need to be initialized)"
        fi
    else
        log_info "Nix not available, skipping flake input validation"
    fi
}

# Main validation function
main() {
    echo
    log_info "Starting NixOS configuration validation..."
    echo
    
    local total_errors=0
    
    # Run all validations
    validate_flake_structure || ((total_errors+=$?))
    echo
    
    validate_nix_files || ((total_errors+=$?))
    echo
    
    validate_shared_resources || ((total_errors+=$?))
    echo
    
    validate_scripts || ((total_errors+=$?))
    echo
    
    check_flake_inputs
    echo
    
    # Summary
    if [[ $total_errors -eq 0 ]]; then
        log_success "All validations passed! NixOS configuration structure is valid."
        echo
        log_info "Next steps:"
        echo "1. On a NixOS system, run: nix flake check"
        echo "2. Deploy with: ./scripts/deploy.sh"
        echo "3. Customize host and user configurations as needed"
    else
        log_error "Validation failed with $total_errors error(s)."
        echo
        log_info "Please fix the errors above before deployment."
        exit 1
    fi
}

# Run validation
main "$@"
