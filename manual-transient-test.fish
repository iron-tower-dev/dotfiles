#!/usr/bin/env fish

echo "Manual transient prompt test"
echo "============================"

# Test if transient prompt can be triggered manually
echo "Setting transient state manually..."
set -g _omp_transient 1

echo "Calling fish_prompt with transient state:"
fish_prompt

echo ""
echo "Resetting transient state..."
set -g _omp_transient 0

echo "Normal prompt:"
fish_prompt

echo ""
echo "This test shows whether the transient prompt mechanism works at all."
echo "If you see different output above (simple vs full prompt), the mechanism works."
echo "The issue is likely just with key binding setup."
