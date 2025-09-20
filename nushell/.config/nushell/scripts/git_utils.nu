# Git Utilities for Nushell
# Advanced Git commands and shortcuts

# Clone and cd into repository
def "gcl" [repo: string, dir?: string] {
  if ($dir | is-empty) {
    let repo_name = ($repo | path basename | str replace ".git" "")
    git clone $repo
    cd $repo_name
  } else {
    git clone $repo $dir
    cd $dir
  }
}

# Create and checkout new branch
def "gcb" [branch: string] {
  git checkout -b $branch
}

# Add all and commit with message
def "gacm" [...message: string] {
  let commit_msg = ($message | str join " ")
  git add .
  git commit -m $commit_msg
}

# Add, commit, and push in one command
def "gacp" [...message: string] {
  let commit_msg = ($message | str join " ")
  git add .
  git commit -m $commit_msg
  git push
}

# Show git status with colors (structured data)
def "gst" [] {
  git status --porcelain | lines | where $it != "" | each { |line|
    let parts = ($line | str trim | split row " " -n 2)
    {
      status: $parts.0
      file: $parts.1
      staged: (if ($parts.0 | str contains "M") or ($parts.0 | str contains "A") or ($parts.0 | str contains "D") { true } else { false })
      modified: (if ($line | str contains " M") or ($line | str contains "??") { true } else { false })
    }
  }
}

# Show pretty git log with structured data
def "glg" [--count (-n): int = 10] {
  git log --oneline --graph --decorate -n $count | lines | each { |line|
    let parts = ($line | parse -r '(?P<graph>[*|\\/ ]+)?\s*(?P<hash>[a-f0-9]+)\s+(?P<message>.*)')
    if ($parts | length) > 0 {
      {
        graph: $parts.0.graph
        hash: $parts.0.hash
        message: $parts.0.message
      }
    }
  } | where hash != null
}

# Undo last commit (keep changes)
def "gundo" [] {
  git reset --soft HEAD~1
  print "Last commit undone (changes kept)"
}

# Completely undo last commit
def "gundo-hard" [] {
  print "This will permanently delete the last commit and all changes!"
  let confirm = (input "Are you sure? (y/N): ")
  if ($confirm | str downcase) == "y" {
    git reset --hard HEAD~1
    print "Last commit undone (hard reset)"
  } else {
    print "Aborted"
  }
}

# Show git branches with additional info
def "gbr" [] {
  git branch -v | lines | each { |line|
    let parts = ($line | str trim | parse -r '(?P<current>[*]?)\s*(?P<name>\S+)\s+(?P<hash>[a-f0-9]+)\s+(?P<message>.*)')
    if ($parts | length) > 0 {
      {
        current: (if $parts.0.current == "*" { true } else { false })
        name: $parts.0.name
        hash: $parts.0.hash
        message: $parts.0.message
      }
    }
  } | where name != null
}

# Show modified files with their changes
def "gchanges" [] {
  git diff --name-status | lines | where $it != "" | each { |line|
    let parts = ($line | split row "\t")
    {
      status: $parts.0
      file: $parts.1
      status_desc: (match $parts.0 {
        "A" => "Added"
        "M" => "Modified"
        "D" => "Deleted"
        "R" => "Renamed"
        "C" => "Copied"
        _ => "Unknown"
      })
    }
  }
}

# Interactive git add
def "gai" [] {
  let files = (git status --porcelain | lines | where $it != "" | each { |line|
    ($line | str trim | split row " " -n 2 | get 1)
  })
  
  if ($files | is-empty) {
    print "No files to add"
    return
  }
  
  print "Files to add:"
  $files | enumerate | each { |item|
    print $"($item.index + 1). ($item.item)"
  }
  
  let selection = (input "Enter file numbers to add (space-separated, 'all' for all): ")
  
  if $selection == "all" {
    git add .
    print "All files added"
  } else {
    let indices = ($selection | split row " " | each { |x| $x | into int })
    let selected_files = ($indices | each { |i| $files | get ($i - 1) })
    $selected_files | each { |file| git add $file }
    print $"Added files: ($selected_files)"
  }
}

# Git stash with description
def "gstash" [message?: string] {
  if ($message | is-empty) {
    git stash
  } else {
    git stash push -m $message
  }
}

# List git stashes
def "gstashes" [] {
  git stash list | lines | each { |line|
    let parts = ($line | parse -r 'stash@\{(?P<index>\d+)\}:\s+(?P<branch>\S+):\s+(?P<message>.*)')
    if ($parts | length) > 0 {
      {
        index: ($parts.0.index | into int)
        branch: $parts.0.branch
        message: $parts.0.message
      }
    }
  } | where index != null
}

# Apply git stash by index
def "gstash-apply" [index: int = 0] {
  git stash apply $"stash@{($index)}"
}

# Drop git stash by index
def "gstash-drop" [index: int = 0] {
  git stash drop $"stash@{($index)}"
}

# Show git remote information
def "gremotes" [] {
  git remote -v | lines | each { |line|
    let parts = ($line | split row "\t")
    let url_type = ($parts.1 | split row " ")
    {
      name: $parts.0
      url: $url_type.0
      type: ($url_type.1 | str replace "(" "" | str replace ")" "")
    }
  }
}

# Clone from GitHub (shorthand)
def "gh-clone" [repo: string] {
  let full_url = $"https://github.com/($repo).git"
  gcl $full_url
}

# Git commit with conventional commit format
def "gconv" [type: string, ...message: string] {
  let commit_msg = ($message | str join " ")
  let full_msg = $"($type): ($commit_msg)"
  git commit -m $full_msg
}

# Common conventional commit shortcuts
def "gfeat" [...message: string] {
  gconv "feat" ...$message
}

def "gfix" [...message: string] {
  gconv "fix" ...$message
}

def "gdocs" [...message: string] {
  gconv "docs" ...$message
}

def "gstyle" [...message: string] {
  gconv "style" ...$message
}

def "grefactor" [...message: string] {
  gconv "refactor" ...$message
}

def "gtest" [...message: string] {
  gconv "test" ...$message
}

# Show git statistics
def "gstats" [] {
  print "Git Repository Statistics:"
  print "========================="
  print ""
  
  print "Commits by author:"
  git shortlog -sn | lines | each { |line|
    let parts = ($line | str trim | split row "\t")
    {
      commits: ($parts.0 | into int)
      author: $parts.1
    }
  }
  
  print ""
  print "Recent activity:"
  git log --oneline -n 5
  
  print ""
  print "Repository info:"
  print $"Total commits: (git rev-list --count HEAD)"
  print $"Branches: (git branch | lines | length)"
  print $"Remotes: (git remote | lines | length)"
}

print $"(ansi blue)Git utilities loaded!(ansi reset)"
