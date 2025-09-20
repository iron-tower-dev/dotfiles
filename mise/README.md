# Mise Tool Version Manager

Mise is a modern tool version manager that replaces asdf. It provides fast, reliable management of multiple runtime versions for various programming languages.

## Quick Start

### Basic Commands

```bash
# List all available tools
mise list-all

# List installed tools
mise list

# Install a tool version
mise install node@20.10.0
mise install python@3.12
mise install go@latest

# Use a tool globally
mise global node@20.10.0
mise global python@3.12

# Use a tool locally (in current project)
mise local node@18.19.0
mise local python@3.11

# Show current tool versions
mise current

# Upgrade all tools to latest
mise upgrade
```

### Project-Specific Versions

Create a `.mise.toml` file in your project root:

```toml
[tools]
node = "20.10.0"
python = "3.12"
go = "1.21.5"

[env]
NODE_ENV = "development"
DEBUG = "1"

[tasks.dev]
run = "npm run dev"

[tasks.test]
run = "npm test"
```

### Environment Management

```bash
# Set environment variables
mise env NODE_ENV=production

# Export environment for current shell
eval "$(mise env)"

# Run command with specific environment
mise exec node@18 -- npm test
```

### Tasks

```bash
# List available tasks
mise tasks

# Run a task
mise run dev
mise run test

# Run task with specific tools
mise run --tool node@18 test
```

## Useful Aliases (Already configured in your shell)

```bash
# Tool management
alias mi='mise install'
alias ml='mise list'
alias mg='mise global'
alias mu='mise use'
alias mw='mise which'
alias mup='mise upgrade'
alias mpr='mise prune'

# List and current status  
alias mls='mise list'
alias mc='mise current'

# Configuration
alias mconf='$EDITOR ~/.config/mise/config.toml'
```

## Advanced Usage

### Plugin Management

```bash
# List available plugins
mise plugin list-all

# Install a plugin
mise plugin install terraform

# Update all plugins
mise plugin update
```

### Tool Information

```bash
# Show tool information
mise which node
mise where node

# List versions for a tool
mise list node
mise list-all node

# Show outdated tools
mise outdated
```

### Configuration

```bash
# Check your mise configuration
mise doctor

# Show configuration
mise config

# Set configuration
mise setting experimental true
```

## Integration with IDEs

### VS Code

Add to your VS Code settings.json:
```json
{
  "terminal.integrated.shellArgs.linux": ["-c", "eval \"$(mise activate bash)\" && exec bash"],
  "terminal.integrated.shellArgs.osx": ["-c", "eval \"$(mise activate zsh)\" && exec zsh"]
}
```

### JetBrains IDEs

Set your tool paths in the IDE settings to point to:
- Node.js: `~/.local/share/mise/installs/node/[version]/bin/node`
- Python: `~/.local/share/mise/installs/python/[version]/bin/python`

## Troubleshooting

### Common Issues

1. **Tool not found after installation**
   ```bash
   # Reload shell configuration
   source ~/.bashrc  # or ~/.zshrc
   # Or restart your terminal
   ```

2. **Permission errors**
   ```bash
   # Ensure proper permissions
   chmod +x ~/.local/share/mise/bin/mise
   ```

3. **Legacy version files not working**
   ```bash
   # Enable legacy version file support
   mise settings legacy_version_file true
   ```

### Environment Debugging

```bash
# Check mise status
mise doctor

# Show environment variables
mise env

# Debug tool resolution
mise which --verbose node

# Show mise logs
MISE_LOG_LEVEL=debug mise install node@latest
```

## Migration from asdf/nvm/pyenv

### From asdf
```bash
# Export asdf configuration
asdf current > ~/.tool-versions

# Import to mise
mise install
```

### From nvm
```bash
# List nvm versions
nvm list

# Install equivalent versions in mise
mise install node@16.20.0
mise install node@18.19.0
mise global node@18.19.0
```

### From pyenv
```bash
# List pyenv versions
pyenv versions

# Install equivalent versions in mise
mise install python@3.11.7
mise install python@3.12.1
mise global python@3.12.1
```

## Best Practices

1. **Always specify exact versions in project `.mise.toml`** for reproducible builds
2. **Use `mise doctor`** regularly to check your setup
3. **Keep your global config minimal** - prefer project-specific configurations
4. **Use tasks** for common project commands
5. **Leverage environment variables** for configuration
6. **Pin versions in CI/CD** environments
7. **Use `mise prune`** regularly to clean up unused versions

## Performance Tips

- Mise is much faster than asdf due to its Rust implementation
- Use `mise install` without version to install all tools from `.mise.toml`
- Leverage parallel installation with `mise install --jobs 4`
- Use `mise exec` for one-off commands with specific tool versions

## Resources

- [Official Documentation](https://mise.jdx.dev/)
- [GitHub Repository](https://github.com/jdx/mise)
- [Available Plugins](https://github.com/mise-plugins)
