#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source helper file
source $SCRIPT_DIR/helper.sh

log_message "Final setup script started"
print_bold_blue "\nCongratulations! Your setup is complete!"

print_success "\nEnjoy your new environment!"

echo "------------------------------------------------------------------------"
