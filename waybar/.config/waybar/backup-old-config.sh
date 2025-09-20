#!/bin/bash

# Backup script for old Waybar configuration
# Run this if you want to revert to the previous setup

BACKUP_DIR="$HOME/.config/waybar-backup-$(date +%Y%m%d-%H%M%S)"

echo "Creating backup directory: $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Function to backup if original exists
backup_file() {
    local file="$1"
    if [[ -f "$HOME/.config/waybar/$file.backup" ]]; then
        cp "$HOME/.config/waybar/$file.backup" "$BACKUP_DIR/$file"
        echo "✅ Backed up original $file"
    else
        echo "⚠️  No backup found for $file"
    fi
}

# Note: This assumes you had backed up your original files
# If not, the enhanced config is now your main config

echo "To restore original configuration:"
echo "1. Stop waybar: killall waybar"
echo "2. Copy files from $BACKUP_DIR back to ~/.config/waybar/"
echo "3. Restart waybar: waybar &"

echo ""
echo "Current enhanced configuration includes:"
echo "- Modern styling with Catppuccin colors"
echo "- Custom scripts for enhanced functionality"
echo "- New modules: weather, system monitoring, network status"
echo "- Improved media controls and power menu"
