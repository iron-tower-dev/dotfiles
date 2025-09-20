# Git Configuration

This directory contains a comprehensive Git configuration with modern features, extensive aliases, and GitHub integration.

## 🚀 Quick Setup

Run the interactive Git setup script:

```bash
# From dotfiles directory
./setup/system/setup-git.sh

# Or from bootstrap menu
./bootstrap.sh --git
```

The setup script will:
- ✅ Configure your Git username and email
- ✅ Generate SSH keys (Ed25519, RSA, or ECDSA)
- ✅ Set up ssh-agent for automatic key loading
- ✅ Integrate with GitHub CLI for seamless authentication
- ✅ Upload SSH keys to GitHub automatically (optional)
- ✅ Test SSH connection to GitHub
- ✅ Create local git configuration overrides

## 📁 Files Overview

- `.gitconfig` - Main git configuration with aliases and modern settings
- `.gitconfig.local` - Local machine-specific overrides (created by setup script)
- `setup-git.sh` - Interactive setup script
- `README.md` - This documentation

## 🎯 Features

### Modern Git Settings

```gitconfig
[pull]
    rebase = true          # Always rebase when pulling
    ff = only              # Fast-forward only merges

[fetch]
    prune = true           # Auto-prune deleted remote branches
    prunetags = true       # Auto-prune deleted remote tags

[push]
    autoSetupRemote = true # Auto-setup remote branch tracking
    followTags = true      # Push tags with commits

[rebase]
    autoStash = true       # Auto-stash changes before rebase
    autoSquash = true      # Auto-squash marked commits

[merge]
    conflictstyle = zdiff3  # Better conflict resolution display
```

### Delta Integration

Enhanced diff viewing with [git-delta](https://github.com/dandavison/delta):
- Side-by-side diffs
- Syntax highlighting  
- Line numbers
- Navigation features

### Comprehensive Aliases

#### Status & Info
- `git st` - Enhanced status with branch info
- `git info` - Show remote information
- `git aliases` - List all configured aliases

#### Branch Operations
- `git co <branch>` - Checkout branch
- `git cob <name>` - Create and checkout new branch
- `git coo <branch>` - Fetch and checkout (safe)
- `git bra` - List all branches (local + remote)
- `git brd <branch>` - Delete branch safely
- `git brD <branch>` - Force delete branch
- `git bdm` - Delete all merged branches

#### Commit Operations
- `git cm "message"` - Quick commit with message
- `git cam "message"` - Add all and commit
- `git commend` - Amend without editing message
- `git reword` - Amend with message editing
- `git undo` - Undo last commit (keep changes)
- `git nuke` - Hard reset to HEAD (lose changes)

#### Stash Management
- `git sl` - List stashes
- `git ss "message"` - Save stash with message
- `git sp` - Pop latest stash
- `git sa` - Apply stash without removing
- `git sd` - Drop stash

#### Enhanced Logging
- `git lg` - Beautiful graph log (all branches)
- `git lga` - Abbreviated graph log
- `git ll` - Detailed log with file stats
- `git last` - Show last commit
- `git filelog <file>` - File-specific history

#### Safe Push Operations
- `git push-new` - Push new branch with upstream tracking
- `git pf` - Push force with lease (safer than --force)

#### Reset Operations
- `git r1` - Soft reset 1 commit back
- `git rh1` - Hard reset 1 commit back
- `git unstage` - Unstage files

#### Utilities
- `git ignored` - Show ignored files
- `git whois <author>` - Find author info
- `git whatis <commit>` - Show commit summary

## 🔐 SSH Key Management

### Supported Key Types

1. **Ed25519** (Recommended)
   - Modern, secure, fast
   - Smaller key size
   - Better performance

2. **RSA 4096-bit**
   - Maximum compatibility
   - Widely supported
   - Larger key size

3. **ECDSA**
   - Good balance of security/compatibility
   - Faster than RSA
   - Smaller than RSA

### SSH Agent Integration

The setup automatically configures SSH agent to:
- Start automatically with your shell
- Load your SSH key on startup
- Persist across terminal sessions

### GitHub Integration

#### Automatic Setup (Recommended)
If GitHub CLI is installed:
```bash
gh auth login --protocol ssh --prefer-ssh
# SSH key is automatically uploaded
```

#### Manual Setup
1. Copy your public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```

2. Go to [GitHub SSH Settings](https://github.com/settings/keys)

3. Click "New SSH key" and paste your public key

4. Test connection:
   ```bash
   ssh -T git@github.com
   ```

## ⚙️ Configuration Details

### Global vs Local Configuration

- **Global**: `~/.gitconfig` - Shared settings across all repositories
- **Local**: `~/.gitconfig.local` - Machine-specific overrides
- **Repository**: `.git/config` - Project-specific settings

### Environment-Specific Configurations

Example local overrides in `~/.gitconfig.local`:

```gitconfig
[user]
    name = Your Name
    email = work@example.com

# Work-specific SSH key
[core]
    sshCommand = ssh -i ~/.ssh/id_ed25519_work

# Enable commit signing
[commit]
    gpgsign = true
[user]
    signingkey = YOUR_GPG_KEY_ID
```

### Repository-Specific Settings

For individual projects:
```bash
# Set project-specific email
git config user.email "project@example.com"

# Use specific SSH key
git config core.sshCommand "ssh -i ~/.ssh/id_rsa_project"
```

## 🔧 Troubleshooting

### Common Issues

#### SSH Connection Problems
```bash
# Test connection
ssh -T git@github.com

# Check SSH agent
ssh-add -l

# Debug SSH connection
ssh -vT git@github.com
```

#### Permission Denied Errors
```bash
# Check key permissions
ls -la ~/.ssh/

# Fix permissions if needed
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh
```

#### Multiple SSH Keys
Configure different keys for different hosts in `~/.ssh/config`:
```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_github

Host gitlab.com
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_ed25519_gitlab
```

### Git Configuration Issues

#### Check Current Configuration
```bash
git config --list --show-origin
git config --global --list
git config --local --list
```

#### Reset Configuration
```bash
# Remove global config
git config --global --unset user.name
git config --global --unset user.email

# Re-run setup
./setup/system/setup-git.sh
```

## 📚 Advanced Usage

### GPG Commit Signing

1. Generate GPG key:
   ```bash
   gpg --full-generate-key
   ```

2. Configure Git:
   ```bash
   git config --global commit.gpgsign true
   git config --global user.signingkey YOUR_KEY_ID
   ```

3. Add to GitHub: Settings → SSH and GPG keys → New GPG key

### Multiple Git Identities

Use [git-identity](https://github.com/madx/git-identity) or conditional includes:

```gitconfig
# In ~/.gitconfig
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
[includeIf "gitdir:~/personal/"]
    path = ~/.gitconfig-personal
```

### Git Hooks Integration

The configuration supports Git hooks for:
- Pre-commit formatting (Prettier, Black, etc.)
- Commit message validation
- Pre-push testing

## 🎨 Customization

### Adding Custom Aliases

Edit `~/.gitconfig.local`:
```gitconfig
[alias]
    # Your custom aliases
    myalias = status --porcelain
    deploy = push origin main
```

### Changing Default Behavior

Modify settings in `~/.gitconfig.local`:
```gitconfig
[push]
    default = current    # Push current branch to same name

[pull]
    rebase = false       # Use merge instead of rebase
```

## 📖 Resources

- [Pro Git Book](https://git-scm.com/book)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Git Delta](https://github.com/dandavison/delta)
- [SSH Key Generation Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

## 🔄 Updates

To update your git configuration:

1. Pull latest dotfiles:
   ```bash
   cd ~/dotfiles
   git pull
   ```

2. Re-deploy git configuration:
   ```bash
   stow -t ~ git
   ```

3. Re-run setup if needed:
   ```bash
   ./setup/system/setup-git.sh
   ```

Your local overrides in `~/.gitconfig.local` will be preserved.
