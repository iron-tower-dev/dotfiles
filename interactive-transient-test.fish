#!/usr/bin/env fish

echo "Testing Oh My Posh transient prompt in Fish shell"
echo "=================================================="
echo ""
echo "Oh My Posh version:" (oh-my-posh --version)
echo "Transient prompt enabled:" $_omp_transient_prompt
echo ""
echo "Test 1: Running a simple command..."
echo "When you run a command and press Enter, the previous prompt should become a simple '❯' arrow"
echo ""

# Test the transient prompt by running some commands
echo "Running: echo 'Hello World'"
echo 'Hello World'

echo ""
echo "Running: ls --help | head -5"
ls --help | head -5

echo ""
echo "Test completed. Check if the previous prompts show only the green ❯ arrow."
echo "The current prompt should show the full Oh My Posh prompt with all segments."
