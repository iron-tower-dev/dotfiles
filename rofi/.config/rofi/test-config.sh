#!/usr/bin/env bash

# Rofi Configuration Test Script
# This script tests the rofi configuration without actually launching the GUI

echo "🧪 Testing Rofi Configuration..."
echo "=================================="

CONFIG_PATH="$HOME/.config/rofi/config.rasi"
THEME_PATH="$HOME/.config/rofi/catppuccin-macchiato.rasi"

# Test if files exist
echo "📁 Checking files..."
if [[ -f "$CONFIG_PATH" ]]; then
    echo "✅ config.rasi found"
else
    echo "❌ config.rasi missing"
    exit 1
fi

if [[ -f "$THEME_PATH" ]]; then
    echo "✅ catppuccin-macchiato.rasi found"
else
    echo "❌ catppuccin-macchiato.rasi missing"
    exit 1
fi

# Test theme validation
echo ""
echo "🎨 Testing theme validation..."
error_output=$(timeout 2 rofi -show drun -theme "$CONFIG_PATH" -no-show-match -filter "nonexistent_test_app_12345" 2>&1)
exit_code=$?
if [[ $exit_code -eq 124 ]]; then
    # Timeout means it loaded successfully and was waiting for input
    if echo "$error_output" | grep -q "Validating the theme failed"; then
        echo "❌ Theme has validation issues:"
        echo "$error_output" | grep "Validating"
    else
        echo "✅ Theme loads without errors"
    fi
elif [[ $exit_code -eq 0 ]]; then
    echo "✅ Theme loads without errors"
else
    echo "❌ Theme has validation issues (exit code: $exit_code)"
    echo "$error_output" | grep -E "(error|failed|invalid)"
fi

# Test available modes
echo ""
echo "🔧 Available modes:"
modes=$(rofi -show-modes 2>/dev/null || echo "drun,run,window,ssh,filebrowser,combi")
IFS=',' read -ra MODE_ARRAY <<< "$modes"
for mode in "${MODE_ARRAY[@]}"; do
    echo "  📋 $mode"
done

# Test launcher script
echo ""
echo "🚀 Testing launcher script..."
if [[ -x "$HOME/.config/rofi/launcher.sh" ]]; then
    echo "✅ Launcher script is executable"
    echo "   Usage: ~/.config/rofi/launcher.sh [mode]"
else
    echo "❌ Launcher script not executable"
fi

echo ""
echo "✨ Configuration test complete!"
echo ""
echo "🎯 Quick start commands:"
echo "   rofi -show drun                    # Launch apps"
echo "   ~/.config/rofi/launcher.sh         # Launch with script"
echo "   ~/.config/rofi/launcher.sh power   # Power menu"
echo ""
echo "🔄 To switch modes while rofi is open:"
echo "   Ctrl+Tab / Alt+Tab  - Next tab"
echo "   Super+1-6           - Direct tab selection"
