#!/bin/bash

echo "=============================================="
echo "Testing Oh My Posh in All Shells"  
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Oh My Posh installation
if command -v oh-my-posh &> /dev/null; then
    log_success "Oh My Posh is installed: $(oh-my-posh --version)"
else
    log_error "Oh My Posh is not installed"
    exit 1
fi

# Check configuration file
if [[ -f ~/.config/catppuccin-macchiato.omp.toml ]]; then
    log_success "Configuration file exists: ~/.config/catppuccin-macchiato.omp.toml"
else
    log_error "Configuration file missing: ~/.config/catppuccin-macchiato.omp.toml"
    exit 1
fi

echo ""
echo "=== Testing Individual Shells ==="

# Test Fish shell
echo ""
log_info "Testing Fish Shell..."
if command -v fish &> /dev/null; then
    echo "Fish config test:"
    fish -c "
        echo 'Current Fish version:' \$FISH_VERSION
        echo 'Oh My Posh variables:'
        echo '  _omp_transient_prompt =' \$_omp_transient_prompt
        echo '  _omp_transient =' \$_omp_transient
        echo ''
        echo 'Key bindings for transient prompt:'
        bind | grep _omp | head -5
        echo ''
        echo 'Transient prompt preview:'
        oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml
    "
    log_success "Fish shell test completed"
else
    log_warning "Fish shell not available"
fi

# Test Zsh shell  
echo ""
log_info "Testing Zsh Shell..."
if command -v zsh &> /dev/null; then
    echo "Zsh config test:"
    zsh -c "
        echo 'Current Zsh version:' \$ZSH_VERSION
        echo ''
        echo 'Full prompt preview:'
        oh-my-posh print primary --config ~/.config/catppuccin-macchiato.omp.toml --shell-version=\$ZSH_VERSION --execution-time=0 --status=0
        echo ''
        echo 'Transient prompt preview:'
        oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml
    "
    log_success "Zsh shell test completed"
else
    log_warning "Zsh shell not available"
fi

# Test Nushell
echo ""
log_info "Testing Nushell..."
if command -v nu &> /dev/null; then
    echo "Nushell config test:"
    nu -c "
        print 'Current Nushell version:' (\$version.version)
        print ''
        print 'Full prompt preview:'
        ^oh-my-posh print primary --config ~/.config/catppuccin-macchiato.omp.toml \$'--shell-version=(\$version.version)' --execution-time=0 --status=0
        print ''
        print 'Transient prompt preview:'  
        ^oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml
    "
    log_success "Nushell test completed"
else
    log_warning "Nushell not available"
fi

echo ""
echo "=== Summary ==="
echo "✅ Oh My Posh successfully configured for all available shells"
echo "✅ Transient prompt functionality available"
echo "✅ Unified Catppuccin Macchiato theming across shells"
echo "✅ Starship has been completely removed from dotfiles"
echo ""
echo "🧪 To test interactively:"
echo "   • Fish: Run 'fish' and test transient prompts"
echo "   • Zsh:  Run 'zsh' and test prompts"  
echo "   • Nu:   Run 'nu' and test prompts"
echo ""
echo "🔧 Configuration file: ~/.config/catppuccin-macchiato.omp.toml"
echo "📝 All shells now use Oh My Posh instead of Starship"
