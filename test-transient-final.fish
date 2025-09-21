#!/usr/bin/env fish

# Test script for Oh My Posh transient prompt in Fish shell
echo "=== Oh My Posh Transient Prompt Test ==="
echo ""

echo "1. Current Oh My Posh version:"
oh-my-posh --version

echo ""
echo "2. Current Fish version:"
echo $FISH_VERSION

echo ""
echo "3. Oh My Posh configuration file:"
if test -f ~/.config/catppuccin-macchiato.omp.toml
    echo "✓ Config file exists: ~/.config/catppuccin-macchiato.omp.toml"
else
    echo "✗ Config file missing: ~/.config/catppuccin-macchiato.omp.toml"
end

echo ""
echo "4. Testing transient prompt rendering:"
oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml

echo ""
echo "5. Oh My Posh variables:"
echo "   _omp_transient_prompt = $_omp_transient_prompt"
echo "   _omp_transient = $_omp_transient"

echo ""
echo "6. Key bindings check:"
set omp_bindings (bind | grep _omp_enter | wc -l)
echo "   Found $omp_bindings Oh My Posh enter key bindings"

if test $omp_bindings -gt 0
    echo "   Bindings found:"
    bind | grep _omp_enter | sed 's/^/   /'
else
    echo "   No enter key bindings found - this may be the issue!"
end

echo ""
echo "7. Manual reinitialization test:"
echo "   Reinitializing Oh My Posh..."

# Clear and reinitialize
bind -e enter -M visual 2>/dev/null
bind -e ctrl-j -M visual 2>/dev/null
bind -e ctrl-c -M default 2>/dev/null
bind -e ctrl-c -M insert 2>/dev/null  
bind -e ctrl-c -M visual 2>/dev/null

oh-my-posh init fish --config ~/.config/catppuccin-macchiato.omp.toml | source

set omp_bindings_after (bind | grep _omp_enter | wc -l)
echo "   After reinit: Found $omp_bindings_after Oh My Posh enter key bindings"

if test $omp_bindings_after -gt 0
    echo "   ✓ Success! Transient prompt should now work"
    echo "   Bindings after reinit:"
    bind | grep _omp_enter | sed 's/^/   /'
else
    echo "   ✗ Still no bindings - there may be a deeper issue"
end

echo ""
echo "=== Test Instructions ==="
echo "If the bindings are now present, test the transient prompt by:"
echo "1. Running some commands (echo, ls, pwd, etc.)"
echo "2. Observing that previous command lines show only '❯' instead of full prompt"
echo "3. The current prompt should still show all segments"

echo ""
echo "If it's still not working, the issue may be:"
echo "- Terminal compatibility (some terminals don't support transient prompts fully)"
echo "- Fish shell configuration conflicts" 
echo "- Oh My Posh version compatibility"
