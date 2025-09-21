# Fish Shell Transient Prompt Test Instructions

## What Should Happen

With Oh My Posh transient prompts enabled, when you run commands in Fish shell:

1. **Current prompt**: Should show full Oh My Posh prompt with all segments:
   ```
   derrick@iron-tower in dotfiles on main ?12 ~15 
   ❯
   ```

2. **Previous prompts**: After executing a command and seeing the output, previous command lines should be simplified to just:
   ```
   ❯ 
   ```

## How to Test

1. Start a new Fish shell:
   ```bash
   fish
   ```

2. Run some commands and observe the prompt behavior:
   ```fish
   echo "Hello World"
   ls -la | head -3
   pwd
   ```

3. Look at your terminal - the previous command lines (above the current one) should show only the green `❯` arrow, not the full prompt.

## Current Configuration Status

- Oh My Posh version: `26.23.8`
- Transient prompt enabled: `$_omp_transient_prompt = 1`
- Configuration file: `~/.config/catppuccin-macchiato.omp.toml`
- Key bindings: Enter key handler is properly configured

## If It's Not Working

Try these debugging steps:

1. Check if the transient prompt renders correctly:
   ```fish
   oh-my-posh print transient --config ~/.config/catppuccin-macchiato.omp.toml
   ```

2. Verify key bindings are loaded:
   ```fish
   bind | grep _omp_enter_key_handler
   ```

3. Check Oh My Posh initialization:
   ```fish
   echo $_omp_transient_prompt
   ```

4. Try reloading your Fish config:
   ```fish
   source ~/.config/fish/config.fish
   ```

## Expected Behavior in Different Scenarios

- **Interactive sessions**: Transient prompt should work
- **Non-interactive sessions**: Transient prompt won't activate
- **Scripts**: Transient prompt won't show
- **Terminal multiplexers**: Should work but may need specific configuration

The transient prompt feature only works in interactive Fish sessions, not when running scripts or commands non-interactively.
