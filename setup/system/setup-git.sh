#!/bin/bash

# Git Setup Script
# Configures git with user credentials, SSH keys, and GitHub integration

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
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[GIT SETUP]${NC} $1"; }

# Git configuration variables
GIT_NAME=""
GIT_EMAIL=""
SSH_KEY_TYPE="ed25519"
SSH_KEY_FILE=""
GITHUB_INTEGRATION=false
GITHUB_USERNAME=""

# Display banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                        GIT SETUP                             ║
    ║                                                               ║
    ║          Configure Git, SSH Keys & GitHub Integration        ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_tools=()
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v ssh-keygen &> /dev/null; then
        missing_tools+=("openssh")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install them first: sudo pacman -S ${missing_tools[*]}"
        exit 1
    fi
    
    log_success "All dependencies are available"
}

# Get user input for git configuration
get_git_config() {
    log_header "GIT CONFIGURATION"
    
    # Check if git is already configured
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")
    
    if [[ -n "$current_name" && -n "$current_email" ]]; then
        log_info "Current git configuration:"
        echo "  Name:  $current_name"
        echo "  Email: $current_email"
        echo
        read -p "Do you want to keep the current configuration? (Y/n): " keep_current
        
        if [[ "$keep_current" =~ ^[Nn]$ ]]; then
            current_name=""
            current_email=""
        else
            GIT_NAME="$current_name"
            GIT_EMAIL="$current_email"
            return
        fi
    fi
    
    # Get user name
    while [[ -z "$GIT_NAME" ]]; do
        if [[ -n "$current_name" ]]; then
            read -p "Enter your full name [$current_name]: " input_name
            GIT_NAME="${input_name:-$current_name}"
        else
            read -p "Enter your full name: " GIT_NAME
        fi
        
        if [[ -z "$GIT_NAME" ]]; then
            log_warning "Name cannot be empty. Please try again."
        fi
    done
    
    # Get user email
    while [[ -z "$GIT_EMAIL" ]]; do
        if [[ -n "$current_email" ]]; then
            read -p "Enter your email address [$current_email]: " input_email
            GIT_EMAIL="${input_email:-$current_email}"
        else
            read -p "Enter your email address: " GIT_EMAIL
        fi
        
        if [[ -z "$GIT_EMAIL" ]]; then
            log_warning "Email cannot be empty. Please try again."
        elif [[ ! "$GIT_EMAIL" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
            log_warning "Please enter a valid email address."
            GIT_EMAIL=""
        fi
    done
    
    log_success "Git configuration collected:"
    echo "  Name:  $GIT_NAME"
    echo "  Email: $GIT_EMAIL"
}

# Configure git with user details
configure_git() {
    log_info "Configuring git with your details..."
    
    # Set user name and email
    git config --global user.name "$GIT_NAME"
    git config --global user.email "$GIT_EMAIL"
    
    # Create local config file for additional overrides
    local local_config="$HOME/.gitconfig.local"
    if [[ ! -f "$local_config" ]]; then
        cat > "$local_config" << EOF
# Local git configuration
# This file is for machine-specific or personal overrides
# It's included by the main .gitconfig file

[user]
	name = $GIT_NAME
	email = $GIT_EMAIL

# Add any local-specific configurations below
# Examples:
# [core]
# 	sshCommand = ssh -i ~/.ssh/id_ed25519_work
# [commit]
# 	gpgsign = true
# [user]
# 	signingkey = YOUR_GPG_KEY_ID
EOF
        log_success "Created local git config at $local_config"
    else
        # Update existing local config
        git config --file "$local_config" user.name "$GIT_NAME"
        git config --file "$local_config" user.email "$GIT_EMAIL"
        log_success "Updated local git config"
    fi
    
    # Configure SSH protocol preferences
    git config --global hub.protocol ssh
    log_info "Configured hub.protocol to use SSH"
    
    log_success "Git configured successfully"
}

# Check for existing SSH keys
check_existing_ssh_keys() {
    log_info "Checking for existing SSH keys..."
    
    local ssh_dir="$HOME/.ssh"
    local existing_keys=()
    
    if [[ -d "$ssh_dir" ]]; then
        for key_type in ed25519 rsa ecdsa; do
            if [[ -f "$ssh_dir/id_$key_type" ]]; then
                existing_keys+=("id_$key_type")
            fi
        done
    fi
    
    if [[ ${#existing_keys[@]} -gt 0 ]]; then
        log_success "Found existing SSH keys:"
        for key in "${existing_keys[@]}"; do
            echo "  - $key"
            # Show public key fingerprint
            ssh-keygen -lf "$ssh_dir/$key" 2>/dev/null || true
        done
        echo
        
        read -p "Do you want to create a new SSH key anyway? (y/N): " create_new
        if [[ ! "$create_new" =~ ^[Yy]$ ]]; then
            # Ask user to select existing key
            echo "Select an existing key to use:"
            select selected_key in "${existing_keys[@]}" "Create new key"; do
                if [[ "$selected_key" == "Create new key" ]]; then
                    break
                elif [[ -n "$selected_key" ]]; then
                    SSH_KEY_FILE="$ssh_dir/$selected_key"
                    log_success "Using existing key: $SSH_KEY_FILE"
                    return 0
                fi
            done
        fi
    fi
    
    return 1  # Need to create new key
}

# Generate SSH key
generate_ssh_key() {
    log_header "SSH KEY GENERATION"
    
    # Check for existing keys first
    if check_existing_ssh_keys; then
        return 0
    fi
    
    # Choose key type
    echo "Select SSH key type:"
    echo "1. Ed25519 (recommended, modern and secure)"
    echo "2. RSA 4096-bit (compatible with older systems)"
    echo "3. ECDSA (good balance of security and compatibility)"
    
    read -p "Choose key type (1-3) [1]: " key_choice
    key_choice=${key_choice:-1}
    
    case $key_choice in
        1)
            SSH_KEY_TYPE="ed25519"
            ;;
        2)
            SSH_KEY_TYPE="rsa"
            ;;
        3)
            SSH_KEY_TYPE="ecdsa"
            ;;
        *)
            log_warning "Invalid choice. Using Ed25519 (recommended)."
            SSH_KEY_TYPE="ed25519"
            ;;
    esac
    
    # Generate unique filename if needed
    SSH_KEY_FILE="$HOME/.ssh/id_${SSH_KEY_TYPE}"
    local counter=1
    while [[ -f "$SSH_KEY_FILE" ]]; do
        SSH_KEY_FILE="$HOME/.ssh/id_${SSH_KEY_TYPE}_${counter}"
        ((counter++))
    done
    
    log_info "Generating $SSH_KEY_TYPE SSH key..."
    
    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    # Generate the key
    local key_comment="$GIT_EMAIL@$(hostname)-$(date +%Y%m%d)"
    
    case $SSH_KEY_TYPE in
        ed25519)
            ssh-keygen -t ed25519 -C "$key_comment" -f "$SSH_KEY_FILE" -N ""
            ;;
        rsa)
            ssh-keygen -t rsa -b 4096 -C "$key_comment" -f "$SSH_KEY_FILE" -N ""
            ;;
        ecdsa)
            ssh-keygen -t ecdsa -b 521 -C "$key_comment" -f "$SSH_KEY_FILE" -N ""
            ;;
    esac
    
    # Set proper permissions
    chmod 600 "$SSH_KEY_FILE"
    chmod 644 "${SSH_KEY_FILE}.pub"
    
    log_success "SSH key generated: $SSH_KEY_FILE"
    
    # Show key fingerprint
    log_info "Key fingerprint:"
    ssh-keygen -lf "$SSH_KEY_FILE"
}

# Add SSH key to ssh-agent
setup_ssh_agent() {
    log_info "Setting up SSH agent..."
    
    # Start ssh-agent if not running
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)"
        log_info "Started SSH agent"
    else
        log_info "SSH agent is already running"
    fi
    
    # Add key to agent
    ssh-add "$SSH_KEY_FILE"
    log_success "SSH key added to agent"
    
    # Add to shell profile for persistence
    local shell_config=""
    if [[ "$SHELL" =~ zsh$ ]]; then
        shell_config="$HOME/.zshrc"
    elif [[ "$SHELL" =~ bash$ ]]; then
        shell_config="$HOME/.bashrc"
    elif [[ "$SHELL" =~ fish$ ]]; then
        shell_config="$HOME/.config/fish/config.fish"
    fi
    
    if [[ -n "$shell_config" && -f "$shell_config" ]]; then
        if ! grep -q "ssh-agent" "$shell_config"; then
            echo "" >> "$shell_config"
            echo "# Auto-start SSH agent" >> "$shell_config"
            if [[ "$SHELL" =~ fish$ ]]; then
                echo "if not pgrep -x ssh-agent > /dev/null" >> "$shell_config"
                echo "    eval (ssh-agent -c)" >> "$shell_config"
                echo "    ssh-add $SSH_KEY_FILE" >> "$shell_config"
                echo "end" >> "$shell_config"
            else
                echo "if ! pgrep -x ssh-agent > /dev/null; then" >> "$shell_config"
                echo "    eval \"\$(ssh-agent -s)\"" >> "$shell_config"
                echo "    ssh-add $SSH_KEY_FILE" >> "$shell_config"
                echo "fi" >> "$shell_config"
            fi
            log_success "Added SSH agent auto-start to $shell_config"
        fi
    fi
}

# GitHub integration
setup_github_integration() {
    log_header "GITHUB INTEGRATION"
    
    read -p "Do you want to set up GitHub integration? (Y/n): " setup_github
    if [[ "$setup_github" =~ ^[Nn]$ ]]; then
        return 0
    fi
    
    GITHUB_INTEGRATION=true
    
    # Get GitHub username
    while [[ -z "$GITHUB_USERNAME" ]]; do
        read -p "Enter your GitHub username: " GITHUB_USERNAME
        if [[ -z "$GITHUB_USERNAME" ]]; then
            log_warning "GitHub username cannot be empty. Please try again."
        fi
    done
    
    log_info "GitHub username: $GITHUB_USERNAME"
    
    # Check if GitHub CLI is installed
    if command -v gh &> /dev/null; then
        log_success "GitHub CLI found"
        
        # Check if already authenticated
        if gh auth status &> /dev/null; then
            log_info "Already authenticated with GitHub CLI"
            
            # Configure GitHub CLI to use SSH protocol
            gh config set git_protocol ssh
            log_info "Configured GitHub CLI to use SSH protocol"
            
            read -p "Do you want to upload your SSH key to GitHub automatically? (Y/n): " upload_key
            if [[ ! "$upload_key" =~ ^[Nn]$ ]]; then
                local pub_key_content=$(cat "${SSH_KEY_FILE}.pub")
                local key_title="$(hostname)-$(date +%Y%m%d)"
                
                if gh ssh-key add "${SSH_KEY_FILE}.pub" --title "$key_title"; then
                    log_success "SSH key uploaded to GitHub successfully!"
                else
                    log_warning "Failed to upload SSH key automatically"
                    show_manual_github_instructions
                fi
            else
                show_manual_github_instructions
            fi
        else
            log_info "GitHub CLI is not authenticated"
            read -p "Do you want to authenticate now? (Y/n): " auth_now
            if [[ ! "$auth_now" =~ ^[Nn]$ ]]; then
                log_info "Starting GitHub CLI authentication..."
                if gh auth login --git-protocol ssh --web; then
                    log_success "GitHub CLI authenticated successfully!"
                    
                    # Configure GitHub CLI to use SSH protocol
                    gh config set git_protocol ssh
                    log_info "Configured GitHub CLI to use SSH protocol"
                    
                    # Upload SSH key
                    local key_title="$(hostname)-$(date +%Y%m%d)"
                    if gh ssh-key add "${SSH_KEY_FILE}.pub" --title "$key_title"; then
                        log_success "SSH key uploaded to GitHub successfully!"
                    else
                        log_warning "Failed to upload SSH key automatically"
                        show_manual_github_instructions
                    fi
                else
                    log_warning "GitHub CLI authentication failed"
                    show_manual_github_instructions
                fi
            else
                show_manual_github_instructions
            fi
        fi
    else
        log_warning "GitHub CLI not found. Install it for seamless GitHub integration:"
        log_info "  sudo pacman -S github-cli"
        show_manual_github_instructions
    fi
}

# Show manual GitHub instructions
show_manual_github_instructions() {
    log_info "Manual GitHub SSH key setup:"
    echo
    echo "1. Copy your public key:"
    echo "   ${CYAN}cat ${SSH_KEY_FILE}.pub${NC}"
    echo
    echo "2. Go to GitHub.com → Settings → SSH and GPG keys"
    echo "3. Click 'New SSH key'"
    echo "4. Paste your public key and give it a descriptive title"
    echo "5. Test the connection with:"
    echo "   ${CYAN}ssh -T git@github.com${NC}"
    echo
    
    # Show the public key
    log_info "Your public key:"
    echo "${GREEN}$(cat "${SSH_KEY_FILE}.pub")${NC}"
    echo
    
    read -p "Press Enter after you've added the key to GitHub..."
}

# Test SSH connection
test_ssh_connection() {
    log_header "TESTING SSH CONNECTION"
    
    if [[ "$GITHUB_INTEGRATION" == true ]]; then
        log_info "Testing GitHub SSH connection..."
        if ssh -T git@github.com -o StrictHostKeyChecking=no 2>&1 | grep -q "successfully authenticated"; then
            log_success "GitHub SSH connection successful!"
        else
            log_warning "GitHub SSH connection test inconclusive. This might be normal."
            log_info "Try running: ssh -T git@github.com"
        fi
    fi
    
    log_success "SSH setup completed"
}

# Show final summary
show_summary() {
    log_header "SETUP SUMMARY"
    
    echo "${GREEN}✓${NC} Git configured:"
    echo "  Name:  $GIT_NAME"
    echo "  Email: $GIT_EMAIL"
    echo
    
    echo "${GREEN}✓${NC} SSH key generated:"
    echo "  Type: $SSH_KEY_TYPE"
    echo "  File: $SSH_KEY_FILE"
    echo
    
    if [[ "$GITHUB_INTEGRATION" == true ]]; then
        echo "${GREEN}✓${NC} GitHub integration configured"
        if [[ -n "${GITHUB_USERNAME:-}" ]]; then
            echo "  Username: $GITHUB_USERNAME"
        fi
        echo
    fi
    
    log_info "Useful git aliases available (try 'git aliases' to see all):"
    echo "  git st     - status"
    echo "  git co     - checkout"
    echo "  git cob    - checkout new branch"
    echo "  git lg     - pretty log graph"
    echo "  git cm     - commit with message"
    echo "  git pf     - push force (safely)"
    echo "  git bdm    - delete merged branches"
    echo
    
    log_success "Git setup completed successfully!"
    if [[ -n "${GITHUB_USERNAME:-}" ]]; then
        echo "You can now clone repositories with: ${CYAN}git clone git@github.com:$GITHUB_USERNAME/repo.git${NC}"
    else
        echo "You can now clone repositories with: ${CYAN}git clone git@github.com:username/repo.git${NC}"
    fi
}

# Main execution
main() {
    display_banner
    echo
    
    check_dependencies
    get_git_config
    configure_git
    generate_ssh_key
    setup_ssh_agent
    setup_github_integration
    test_ssh_connection
    show_summary
}

# Run main function
main "$@"
