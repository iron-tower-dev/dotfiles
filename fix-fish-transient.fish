#!/usr/bin/env fish

echo "Fixing Oh My Posh transient prompt in Fish..."

# Create a simple wrapper function that handles both OhMyPosh and abbr_tips
function omp_transient_enter
    # Handle Oh My Posh transient prompt
    if set -q _omp_transient_prompt; and test "$_omp_transient_prompt" = "1"
        if commandline --paging-mode
            commandline --function execute
            return
        end
        
        if commandline --is-valid || test -z (commandline --current-buffer | string trim -l | string collect)
            set -g _omp_new_prompt 1
            set -g _omp_tooltip_command ''
            set -g _omp_transient 1
            commandline --function repaint
        end
    end
    
    # Handle abbr_tips if available
    if functions -q __abbr_tips_bind_newline
        __abbr_tips_bind_newline
    else
        commandline --function execute
    end
end

# Set the key bindings
bind \r omp_transient_enter
bind \n omp_transient_enter  
bind -M insert \r omp_transient_enter
bind -M insert \n omp_transient_enter

echo "✅ Oh My Posh transient prompt bindings fixed!"
echo "🧪 Test by running commands in this Fish session"
echo "📝 Previous command lines should show only '❯' after running commands"
