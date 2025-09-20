# Git utility functions for Fish shell

# Function to clone and cd into repository
function gcl
    if test (count $argv) -eq 1
        git clone $argv[1]
        set repo_name (basename $argv[1] .git)
        cd $repo_name
    else if test (count $argv) -eq 2
        git clone $argv[1] $argv[2]
        cd $argv[2]
    else
        echo "Usage: gcl <repo_url> [directory_name]"
        return 1
    end
end

# Function to create and checkout new branch
function gcb
    if test (count $argv) -eq 1
        git checkout -b $argv[1]
    else
        echo "Usage: gcb <branch_name>"
        return 1
    end
end

# Function to add all and commit with message
function gacm
    if test (count $argv) -ge 1
        git add .
        git commit -m "$argv"
    else
        echo "Usage: gacm <commit_message>"
        return 1
    end
end

# Function to add, commit, and push in one command
function gacp
    if test (count $argv) -ge 1
        git add .
        git commit -m "$argv"
        git push
    else
        echo "Usage: gacp <commit_message>"
        return 1
    end
end

# Function to show git status with colors
function gst
    git status --short --branch
end

# Function to show pretty git log
function glg
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit $argv
end

# Function to undo last commit (keep changes)
function gundo
    git reset --soft HEAD~1
end

# Function to completely undo last commit
function gundo_hard
    echo "This will permanently delete the last commit and all changes!"
    read -P "Are you sure? (y/N): " -n 1 confirm
    if test "$confirm" = "y" -o "$confirm" = "Y"
        git reset --hard HEAD~1
        echo "Last commit undone (hard reset)"
    else
        echo "Aborted"
    end
end
