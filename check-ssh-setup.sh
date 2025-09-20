#!/bin/bash

# Quick SSH Setup Verification Script
# Checks if SSH keys are set up and working with GitHub

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔑 Checking SSH setup for GitHub...${NC}"

# Check if SSH keys exist
if [[ -f ~/.ssh/id_ed25519 ]] || [[ -f ~/.ssh/id_rsa ]]; then
    echo -e "${GREEN}✅ SSH keys found${NC}"
    
    # Test GitHub connection
    echo "   Testing GitHub connection..."
    if ssh -T git@github.com 2>&1 | grep -q "Hi.*successfully authenticated"; then
        echo -e "${GREEN}✅ GitHub SSH connection working${NC}"
        USERNAME=$(ssh -T git@github.com 2>&1 | grep -o 'Hi [^!]*' | cut -d' ' -f2)
        echo -e "   Connected as: ${GREEN}$USERNAME${NC}"
        echo -e "${GREEN}🎉 SSH setup is ready for GitHub!${NC}"
    else
        echo -e "${RED}❌ GitHub SSH connection failed${NC}"
        echo -e "${YELLOW}💡 Try starting SSH agent and adding your key:${NC}"
        echo "   eval \"\$(ssh-agent -s)\" && ssh-add ~/.ssh/id_ed25519"
        echo -e "${YELLOW}💡 Or run the git setup script:${NC}"
        echo "   ./setup/system/setup-git.sh"
    fi
else
    echo -e "${RED}❌ No SSH keys found${NC}"
    echo -e "${YELLOW}💡 Run the git setup script to create SSH keys:${NC}"
    echo "   ./setup/system/setup-git.sh"
fi

echo
echo -e "${YELLOW}📋 Ready to push to GitHub? Run:${NC}"
echo "   ./setup-github-repo.sh"
