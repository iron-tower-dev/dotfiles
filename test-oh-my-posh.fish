#!/usr/bin/env fish

echo "=== Oh My Posh with Transient Prompt Test ==="
echo ""

echo "✅ Oh My Posh Configuration Status:"
echo "   Version: "(oh-my-posh --version)
echo "   Config: ~/.config/catppuccin-macchiato.omp.toml"
echo "   Theme: Catppuccin Macchiato with transient prompt"
echo ""

echo "🎨 Full Prompt Preview:"
oh-my-posh print primary --config ~/.config/catppuccin-macchiato.omp.toml

echo ""
echo "⚡ Transient Prompt Preview (what previous commands will show):"
oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml

echo ""
echo "🎯 Key Features:"
echo "   • Catppuccin Macchiato colors throughout"
echo "   • User@hostname with teal color"
echo "   • Directory path with peach color"
echo "   • Git branch and status with mauve color"
echo "   • Programming language versions (Python, Node, Go, Rust)"
echo "   • Execution time on right side"
echo "   • Exit code indication on errors"
echo "   • 🔥 TRANSIENT PROMPT: Previous commands show just '❯ '"
echo ""

echo "🚀 How to Test Transient Prompt:"
echo "   1. Start Fish with Oh My Posh: SKIP_ZELLIJ=1 fish"
echo "   2. Run several commands:"
echo "      echo 'Command 1'"
echo "      ls -la"
echo "      pwd"
echo "      echo 'Command 2'"
echo "   3. Previous commands should collapse to just '❯ '"
echo "   4. Current command shows full prompt with context"
echo ""

echo "🔄 To Switch Back to Starship:"
echo "   Edit ~/.config/fish/config.fish and uncomment Starship, comment Oh My Posh"
echo ""

echo "The transient prompt feature in Oh My Posh should give you exactly"
echo "what you were looking for - previous command lines showing just '❯ '"
echo "while the current prompt shows full context!"
