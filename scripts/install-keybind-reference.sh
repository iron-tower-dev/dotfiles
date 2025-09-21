#!/bin/bash
# Installation script for Keybinding Reference Panel

set -e

echo "🔧 Installing Keybinding Reference Panel..."

# Check if Python GTK4 dependencies are available
if ! python3 -c "import gi; gi.require_version('Gtk', '4.0'); gi.require_version('Adw', '1')" 2>/dev/null; then
    echo "📦 Installing required Python GTK4 packages..."
    
    # Install GTK4 and libadwaita development packages
    sudo pacman -S --needed python-gobject gtk4 libadwaita python-cairo || {
        echo "❌ Failed to install required packages. Please install manually:"
        echo "   sudo pacman -S python-gobject gtk4 libadwaita python-cairo"
        exit 1
    }
fi

# Make the script executable
chmod +x /home/derrick/dotfiles/scripts/keybind-reference.py

# Test the application
echo "🧪 Testing application..."
if python3 /home/derrick/dotfiles/scripts/keybind-reference.py --help >/dev/null 2>&1; then
    echo "✅ Application installed successfully!"
    echo ""
    echo "🎹 Usage:"
    echo "  • Press SUPER + / to open keybinding reference"
    echo "  • Click the keyboard icon (󰌌) in Waybar"
    echo "  • Press Escape to close the panel"
    echo ""
    echo "📍 The panel will appear floating on the right side of your screen"
else
    echo "❌ Application test failed. Check dependencies and try again."
    exit 1
fi

echo "🎨 Keybinding Reference Panel is ready to use!"
