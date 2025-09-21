# 🚀 GitHub Repository Setup Guide

This guide will help you upload your dotfiles to GitHub and replace your existing "dotfiles" repository.

## ✅ Prerequisites Check

Your current setup:
- ✅ Git configured (Derrick Southworth, derricksouthworth@gmail.com)
- ✅ SSH keys available (`~/.ssh/id_ed25519`)
- ✅ GitHub SSH authentication working (as `iron-tower-dev`)
- ✅ SSH agent started and key added

## 🎯 Quick Setup (Recommended)

**Option 1: Automated Setup**
```bash
# Make sure SSH agent is running (do this first!)
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

# Run the automated setup script
./setup/system/setup-github-repo.sh
```

This script will:
1. Install GitHub CLI if needed
2. Authenticate with GitHub
3. Initialize git repository
4. Create appropriate .gitignore
5. Commit all files
6. Create/update the repository on GitHub
7. Push everything to GitHub

**Option 2: Manual Setup**
If you prefer to do it manually:

```bash
# 1. Start SSH agent and add key
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519

# 2. Initialize git repository
git init
git branch -M main

# 3. Create .gitignore (optional - the script creates a good one)
# See the setup/system/setup-github-repo.sh for the recommended .gitignore content

# 4. Add and commit files
git add .
git commit -m "🎉 Initial commit: Modern Arch Linux dotfiles"

# 5. Create repository on GitHub (go to https://github.com/new)
#    - Repository name: dotfiles
#    - Make it public
#    - Don't initialize with README

# 6. Add remote and push
git remote add origin git@github.com:iron-tower-dev/dotfiles.git
git push -u origin main --force
```

## 🔧 Troubleshooting

### SSH Agent Issues
If you get "Could not open a connection to your authentication agent":
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### SSH Key Not Recognized
Test your connection:
```bash
ssh -T git@github.com
# Should show: Hi iron-tower-dev! You've successfully authenticated...
```

### Repository Already Exists
The script will ask if you want to:
1. Delete existing repo and create new one (DESTRUCTIVE)
2. Push to existing repo (will overwrite)
3. Cancel and handle manually

### GitHub CLI Authentication
If GitHub CLI authentication fails, you can:
1. Create the repository manually on GitHub.com
2. Add the remote manually: `git remote add origin git@github.com:iron-tower-dev/dotfiles.git`

## 📋 After Setup

Once your repository is on GitHub:

**Clone on another machine:**
```bash
git clone git@github.com:iron-tower-dev/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

**Update your dotfiles:**
```bash
git add .
git commit -m "Update configurations"
git push
```

**Share your setup:**
- Repository URL: https://github.com/iron-tower-dev/dotfiles
- SSH Clone: `git@github.com:iron-tower-dev/dotfiles.git`
- HTTPS Clone: `https://github.com/iron-tower-dev/dotfiles.git`

## 🎨 Repository Features

Your repository will have:
- ✅ Comprehensive README with setup instructions
- ✅ Proper .gitignore for dotfiles
- ✅ GitHub topics: dotfiles, hyprland, waybar, catppuccin, arch-linux
- ✅ Professional commit message and description
- ✅ All your configurations properly organized

## 🔐 Security Notes

The .gitignore excludes:
- SSH private keys
- Personal/sensitive data
- Cache directories
- Temporary files
- Local configuration overrides

Your `~/.gitconfig.local` template is included but won't contain your actual credentials.

---

**Ready to proceed? Run: `./setup/system/setup-github-repo.sh`**
