#!/bin/bash

# GitHub Repository Setup Script
# Initializes git repository and pushes to GitHub, replacing existing repo

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
log_header() { echo -e "${PURPLE}[GITHUB SETUP]${NC} $1"; }

# Configuration
REPO_NAME="dotfiles"
GITHUB_USERNAME="iron-tower-dev"  # Your actual GitHub username
REPO_DESCRIPTION="🌸 Modern Arch Linux dotfiles with Hyprland, Waybar, and Catppuccin theming"

# Display banner
display_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    GITHUB REPOSITORY SETUP                   ║
    ║                                                               ║
    ║            Push Dotfiles to GitHub & Replace Existing        ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
EOF
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "bootstrap.sh" || ! -f "README.md" ]]; then
        log_error "This script must be run from the dotfiles directory"
        log_info "Please run: cd ~/dotfiles && ./setup/system/setup-github-repo.sh"
        exit 1
    fi
    log_success "Running from dotfiles directory"
}

# Install GitHub CLI if needed
install_github_cli() {
    if ! command -v gh &> /dev/null; then
        log_info "GitHub CLI not found. Installing..."
        if sudo pacman -S --needed --noconfirm github-cli; then
            log_success "GitHub CLI installed successfully"
        else
            log_error "Failed to install GitHub CLI"
            exit 1
        fi
    else
        log_success "GitHub CLI is already installed"
    fi
}

# Check git configuration
check_git_config() {
    local git_name=$(git config --global user.name || echo "")
    local git_email=$(git config --global user.email || echo "")
    
    if [[ -z "$git_name" || -z "$git_email" ]]; then
        log_error "Git is not configured with user name and email"
        log_info "Please run the git setup script first: ./setup/system/setup-git.sh"
        exit 1
    fi
    
    log_success "Git is configured:"
    echo "  Name:  $git_name"
    echo "  Email: $git_email"
}

# Authenticate with GitHub CLI
authenticate_github() {
    log_header "GITHUB AUTHENTICATION"
    
    if gh auth status &> /dev/null; then
        log_success "Already authenticated with GitHub CLI"
        
        # Ensure GitHub CLI is configured to use SSH protocol
        gh config set git_protocol ssh
        log_info "Configured GitHub CLI to use SSH protocol"
        
        return 0
    fi
    
    log_info "Authenticating with GitHub CLI..."
    log_info "Please follow the prompts to authenticate with your GitHub account"
    
    if gh auth login --git-protocol ssh --web; then
        log_success "GitHub CLI authenticated successfully!"
        
        # Configure GitHub CLI to use SSH protocol
        gh config set git_protocol ssh
        log_info "Configured GitHub CLI to use SSH protocol"
    else
        log_error "GitHub CLI authentication failed"
        log_info "You can continue manually by:"
        log_info "1. Creating the repository on GitHub.com"
        log_info "2. Adding it as a remote: git remote add origin git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
        read -p "Press Enter to continue with manual setup, or Ctrl+C to exit..."
        return 1
    fi
}

# Initialize git repository
initialize_git() {
    log_header "GIT REPOSITORY INITIALIZATION"
    
    if [[ -d ".git" ]]; then
        log_warning "Git repository already exists"
        read -p "Do you want to reinitialize? This will remove git history (y/N): " reinit
        if [[ "$reinit" =~ ^[Yy]$ ]]; then
            rm -rf .git
            log_info "Removed existing git repository"
        else
            log_info "Using existing git repository"
            return 0
        fi
    fi
    
    log_info "Initializing git repository..."
    git init
    git branch -M main
    
    log_success "Git repository initialized with main branch"
}

# Create .gitignore file
create_gitignore() {
    log_info "Creating .gitignore file..."
    
    cat > .gitignore << 'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor and IDE files
.vscode/
.idea/
*.swp
*.swo
*~
.vim/

# Temporary files
*.tmp
*.temp
*.bak
*.backup
*.old

# Logs
*.log
logs/

# Local configuration files (these should be machine-specific)
.env
.env.local
*.local
!.gitconfig.local  # This is a template, should be included

# Cache directories
.cache/
__pycache__/
*.pyc
*.pyo

# Package managers
node_modules/
.npm/
.yarn/

# Build artifacts
dist/
build/
target/
*.o
*.so
*.dll

# Personal/sensitive data
secrets/
private/
.ssh/id_*
.ssh/known_hosts
.gnupg/
.password-store/

# Stow should ignore these
.stow-local-ignore

# Test files
test/
tests/
*.test

# Documentation build
_site/
.jekyll-cache/

# Compiled binaries
*.exe
*.bin
EOF

    log_success "Created .gitignore file"
}

# Create repository on GitHub
create_github_repo() {
    log_header "GITHUB REPOSITORY CREATION"
    
    # Check if repo already exists
    if gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
        log_warning "Repository $GITHUB_USERNAME/$REPO_NAME already exists on GitHub"
        
        echo "What would you like to do?"
        echo "1. Delete existing repo and create new one (DESTRUCTIVE)"
        echo "2. Push to existing repo (will force push and overwrite)"
        echo "3. Cancel and handle manually"
        
        read -p "Choose option (1-3): " choice
        
        case $choice in
            1)
                log_warning "This will permanently delete the existing repository!"
                read -p "Are you absolutely sure? Type 'DELETE' to confirm: " confirm
                if [[ "$confirm" == "DELETE" ]]; then
                    gh repo delete "$GITHUB_USERNAME/$REPO_NAME" --yes
                    log_info "Existing repository deleted"
                else
                    log_info "Deletion cancelled"
                    exit 1
                fi
                ;;
            2)
                log_info "Will push to existing repository"
                return 0
                ;;
            3)
                log_info "Setup cancelled"
                exit 0
                ;;
            *)
                log_error "Invalid choice"
                exit 1
                ;;
        esac
    fi
    
    log_info "Creating new repository: $REPO_NAME"
    if gh repo create "$REPO_NAME" --public --description "$REPO_DESCRIPTION" --source . --remote origin --push; then
        log_success "Repository created and pushed successfully!"
        return 0
    else
        log_warning "Failed to create repository via GitHub CLI"
        log_info "Creating repository manually..."
        
        # Manual creation fallback
        if gh repo create "$REPO_NAME" --public --description "$REPO_DESCRIPTION"; then
            git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
            log_success "Repository created manually"
        else
            log_error "Failed to create repository"
            return 1
        fi
    fi
}

# Stage and commit files
commit_files() {
    log_header "COMMITTING FILES"
    
    log_info "Staging all files..."
    git add .
    
    log_info "Creating initial commit..."
    git commit -m "🎉 Initial commit: Modern Arch Linux dotfiles

✨ Features:
- Hyprland compositor with smooth animations
- Waybar status bar with custom modules
- Catppuccin Macchiato theming throughout
- Fish shell with Starship prompt
- Comprehensive git configuration with 50+ aliases
- Mise programming language version manager
- Automated setup scripts
- SSH key generation and GitHub integration

🚀 Quick setup: ./bootstrap.sh

This is a complete desktop environment setup for Arch Linux with modern
tools, beautiful theming, and automated configuration management."

    log_success "Initial commit created"
}

# Push to GitHub
push_to_github() {
    log_header "PUSHING TO GITHUB"
    
    # Add remote if it doesn't exist
    if ! git remote get-url origin &> /dev/null; then
        log_info "Adding GitHub remote..."
        git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
    fi
    
    log_info "Pushing to GitHub..."
    if git push -u origin main --force; then
        log_success "Successfully pushed to GitHub!"
    else
        log_error "Failed to push to GitHub"
        log_info "You may need to set up SSH keys. Run: ./setup/system/setup-git.sh"
        return 1
    fi
}

# Set up repository settings
configure_repo_settings() {
    log_header "CONFIGURING REPOSITORY"
    
    log_info "Setting up repository topics and settings..."
    
    # Add topics to repository
    gh repo edit --add-topic "dotfiles" \
                 --add-topic "hyprland" \
                 --add-topic "waybar" \
                 --add-topic "catppuccin" \
                 --add-topic "arch-linux" \
                 --add-topic "wayland" \
                 --add-topic "fish-shell" \
                 --add-topic "starship" \
                 --add-topic "theming" \
                 --add-topic "desktop-environment" \
                 --add-topic "automation" || log_warning "Failed to add topics (not critical)"
    
    # Enable GitHub Pages if README is good
    # gh repo edit --enable-pages --pages-branch main --pages-path / || log_warning "Failed to enable pages"
    
    log_success "Repository configured"
}

# Show final information
show_completion() {
    log_header "SETUP COMPLETE"
    
    echo "${GREEN}🎉 Your dotfiles are now on GitHub!${NC}"
    echo
    echo "📍 Repository: ${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
    echo "🔗 SSH Clone:  ${CYAN}git@github.com:$GITHUB_USERNAME/$REPO_NAME.git${NC}"
    echo "📋 HTTPS Clone: ${CYAN}https://github.com/$GITHUB_USERNAME/$REPO_NAME.git${NC}"
    echo
    echo "🛠️  Next steps:"
    echo "  1. Check your repository online: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
    echo "  2. Share your dotfiles with others!"
    echo "  3. Set up branch protection rules if desired"
    echo
    echo "📝 To update your repository later:"
    echo "  ${CYAN}git add .${NC}"
    echo "  ${CYAN}git commit -m \"Your commit message\"${NC}"
    echo "  ${CYAN}git push${NC}"
    echo
    echo "🔄 To clone on another machine:"
    echo "  ${CYAN}git clone git@github.com:$GITHUB_USERNAME/$REPO_NAME.git ~/dotfiles${NC}"
    echo "  ${CYAN}cd ~/dotfiles && ./bootstrap.sh${NC}"
}

# Main execution
main() {
    display_banner
    echo
    
    check_directory
    install_github_cli
    check_git_config
    
    # Try to authenticate with GitHub
    if ! authenticate_github; then
        log_warning "Proceeding with manual setup..."
    fi
    
    initialize_git
    create_gitignore
    commit_files
    
    # Try to create repository and push
    if command -v gh &> /dev/null && gh auth status &> /dev/null; then
        create_github_repo
        configure_repo_settings
    else
        log_warning "GitHub CLI not authenticated. Please create repository manually:"
        log_info "1. Go to https://github.com/new"
        log_info "2. Repository name: $REPO_NAME"
        log_info "3. Make it public"
        log_info "4. Don't initialize with README (we have one)"
        log_info "5. Then run: git remote add origin git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
        read -p "Press Enter after creating the repository..."
        git remote add origin "git@github.com:$GITHUB_USERNAME/$REPO_NAME.git"
    fi
    
    push_to_github
    show_completion
}

# Run main function
main "$@"
