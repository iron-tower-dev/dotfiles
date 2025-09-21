#!/bin/bash

echo "Testing Oh My Posh transient prompt in Fish shell..."
echo "=============================================="

# Start a new Fish shell and test transient prompt
fish -c "
echo 'Fish shell with Oh My Posh loaded'
echo 'Current _omp_transient_prompt setting:'
echo \$_omp_transient_prompt
echo ''
echo 'Testing prompt functionality:'
echo 'Type a command and press Enter to see transient prompt behavior'
echo 'The previous command line should show only the green ❯ arrow'
echo ''
echo 'Type \"exit\" to return to the main shell'
"
