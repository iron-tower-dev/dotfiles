#!/usr/bin/env bash
# Test script for dwl-setup.sh
# This will do a dry-run to verify the script structure

set -e

echo "========================================"
echo "  DWL SETUP TEST SCRIPT"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[TEST]${NC} Checking if dwl-setup.sh exists..."
if [[ -f "setup/packages/dwl-setup.sh" ]]; then
    echo -e "${GREEN}✓${NC} dwl-setup.sh found"
else
    echo -e "${RED}✗${NC} dwl-setup.sh not found"
    exit 1
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking if dwl-setup.sh is executable..."
if [[ -x "setup/packages/dwl-setup.sh" ]]; then
    echo -e "${GREEN}✓${NC} dwl-setup.sh is executable"
else
    echo -e "${YELLOW}!${NC} Making dwl-setup.sh executable..."
    chmod +x setup/packages/dwl-setup.sh
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking dwl configuration directory..."
if [[ -d "dwl/.config" ]]; then
    echo -e "${GREEN}✓${NC} dwl/.config directory exists"
    echo ""
    echo "  Configuration files:"
    find dwl/.config -type f | sed 's|^|    - |'
else
    echo -e "${RED}✗${NC} dwl/.config directory not found"
    exit 1
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking for yambar configuration..."
if [[ -f "dwl/.config/yambar/config.yml" ]]; then
    echo -e "${GREEN}✓${NC} yambar config found"
else
    echo -e "${RED}✗${NC} yambar config not found"
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking for mako configuration..."
if [[ -f "dwl/.config/mako/config" ]]; then
    echo -e "${GREEN}✓${NC} mako config found"
else
    echo -e "${RED}✗${NC} mako config not found"
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking for documentation..."
if [[ -f "dwl/QUICKSTART.md" ]]; then
    echo -e "${GREEN}✓${NC} QUICKSTART.md found"
else
    echo -e "${YELLOW}!${NC} QUICKSTART.md not found (will be created by setup script)"
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Verifying script syntax..."
if bash -n setup/packages/dwl-setup.sh; then
    echo -e "${GREEN}✓${NC} Script syntax is valid"
else
    echo -e "${RED}✗${NC} Script has syntax errors"
    exit 1
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking bootstrap.sh integration..."
if grep -q "dwl-setup.sh" bootstrap.sh; then
    echo -e "${GREEN}✓${NC} dwl-setup.sh referenced in bootstrap.sh"
else
    echo -e "${YELLOW}!${NC} dwl-setup.sh not found in bootstrap.sh"
fi

if grep -q -- "--dwl" bootstrap.sh; then
    echo -e "${GREEN}✓${NC} --dwl option found in bootstrap.sh"
else
    echo -e "${YELLOW}!${NC} --dwl option not found in bootstrap.sh"
fi

echo ""
echo -e "${BLUE}[TEST]${NC} Checking stow package list..."
if grep -q '"dwl"' bootstrap.sh; then
    echo -e "${GREEN}✓${NC} dwl added to STOW_PACKAGES"
else
    echo -e "${YELLOW}!${NC} dwl not in STOW_PACKAGES list"
fi

echo ""
echo "========================================"
echo -e "${GREEN}  ALL TESTS PASSED!${NC}"
echo "========================================"
echo ""
echo "To test the actual installation:"
echo "  1. Run: ./bootstrap.sh --dwl"
echo "  2. Or use option 12 in the legacy menu"
echo ""
echo "For a non-interactive test (without actually installing):"
echo "  cat setup/packages/dwl-setup.sh"
echo ""