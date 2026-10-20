#!/usr/bin/env bash
# ==============================================================================
# 🌿 10-git.aliases.bash — Advanced Git Shortcuts, Workflows & Log Visualizers
# ==============================================================================
# Production-grade Git shortcuts, log visualizers, branch cleanup routines,
# stashing helpers, commit ergonomics, and defensive repository safety resets.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 📖 Everyday Git Shortcuts
# ------------------------------------------------------------------------------

# @name: g
# @category: Git
# @description: Short alias for the git command-line tool.
# @os: cross-platform
alias g='git'

# @name: gs
# @category: Git
# @description: Show working tree status in short format with active branch name.
# @os: cross-platform
alias gs='git status --short --branch'

# @name: gst
# @category: Git
# @description: Show complete working tree status.
# @os: cross-platform
alias gst='git status'

# @name: ga
# @category: Git
# @description: Add file contents to staging index.
# @os: cross-platform
alias ga='git add'

# @name: gaa
# @category: Git
# @description: Add all changes across entire repository tree to staging index.
# @os: cross-platform
alias gaa='git add --all'

# @name: gap
# @category: Git
# @description: Interactively review and stage changes hunk-by-hunk.
# @os: cross-platform
alias gap='git add --patch'

# ------------------------------------------------------------------------------
# 🔍 Diff & Inspection Utilities
# ------------------------------------------------------------------------------

# @name: gd
# @category: Git
# @description: Show unstaged working directory differences.
# @os: cross-platform
alias gd='git diff'

# @name: gds
# @category: Git
# @description: Show changes staged for the next commit.
# @os: cross-platform
alias gds='git diff --staged'

# @name: gdw
# @category: Git
# @description: Show differences highlighted at the individual word level.
# @os: cross-platform
alias gdw='git diff --word-diff'

# ------------------------------------------------------------------------------
# 🌿 Branch Management & Cleanup
# ------------------------------------------------------------------------------

# @name: gb
# @category: Git
# @description: List local branches with active branch highlighted.
# @os: cross-platform
alias gb='git branch'

# @name: gba
# @category: Git
# @description: List all local and remote tracking branches.
# @os: cross-platform
alias gba='git branch --all'

# @name: gbd
# @category: Git
# @description: Safely delete a fully merged local branch.
# @os: cross-platform
alias gbd='git branch --delete'

# @name: gbD
# @category: Git
# @description: Force-delete a local branch regardless of merge status.
# @os: cross-platform
alias gbD='git branch --delete --force'

# @name: gbclean
# @category: Git
# @description: Delete local branches that have already been merged into default branch.
# @os: cross-platform
gbclean() {
    local default_branch
    default_branch="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
    default_branch="${default_branch:-main}"

    printf 'Scanning for local branches merged into %s...\n' "$default_branch"
    git branch --merged "$default_branch" | grep -v '^\*' | grep -v -E "^[[:space:]]*(master|main|develop|dev|trunk)$" | while read -r branch; do
        branch="${branch## }"
        [ -n "$branch" ] && git branch -d "$branch"
    done
}

# ------------------------------------------------------------------------------
# ✍️ Commit Operations
# ------------------------------------------------------------------------------

# @name: gc
# @category: Git
# @description: Record changes to the repository via commit editor.
# @os: cross-platform
alias gc='git commit'

# @name: gcm
# @category: Git
# @description: Record changes to the repository with an inline commit message.
# @os: cross-platform
alias gcm='git commit -m'

# @name: gca
# @category: Git
# @description: Amend the previous commit while opening editor for commit message.
# @os: cross-platform
alias gca='git commit --amend'

# @name: gcan
# @category: Git
# @description: Amend the previous commit reusing existing message without editing.
# @os: cross-platform
alias gcan='git commit --amend --no-edit'

# ------------------------------------------------------------------------------
# 🔀 Switch, Restore & Checkout
# ------------------------------------------------------------------------------

# @name: gsw
# @category: Git
# @description: Switch to an existing branch.
# @os: cross-platform
alias gsw='git switch'

# @name: gswc
# @category: Git
# @description: Create and switch to a new branch.
# @os: cross-platform
alias gswc='git switch --create'

# @name: grs
# @category: Git
# @description: Restore working tree files from HEAD.
# @os: cross-platform
alias grs='git restore'

# @name: grss
# @category: Git
# @description: Unstage changes while preserving them in the working tree.
# @os: cross-platform
alias grss='git restore --staged'

# @name: gco
# @category: Git
# @description: Checkout a branch or switch paths in working tree.
# @os: cross-platform
alias gco='git checkout'

# @name: gcb
# @category: Git
# @description: Create and checkout a new branch (classic syntax).
# @os: cross-platform
alias gcb='git checkout -b'

# ------------------------------------------------------------------------------
# 🚀 Remote, Push & Pull
# ------------------------------------------------------------------------------

# @name: gf
# @category: Git
# @description: Download objects and refs from remote repository.
# @os: cross-platform
alias gf='git fetch'

# @name: gfa
# @category: Git
# @description: Fetch all remotes and prune obsolete remote tracking branches.
# @os: cross-platform
alias gfa='git fetch --all --prune'

# @name: gp
# @category: Git
# @description: Update remote refs along with associated objects.
# @os: cross-platform
alias gp='git push'

# @name: gpu
# @category: Git
# @description: Push current branch and set upstream tracking reference on origin.
# @os: cross-platform
alias gpu='git push --set-upstream origin HEAD'

# @name: gpf
# @category: Git
# @description: Push with lease verification to safely prevent overwriting peer commits.
# @os: cross-platform
alias gpf='git push --force-with-lease'

# @name: gl
# @category: Git
# @description: Fetch from and integrate with remote repository or branch.
# @os: cross-platform
alias gl='git pull'

# @name: glr
# @category: Git
# @description: Fetch from remote and rebase current branch on top of upstream.
# @os: cross-platform
alias glr='git pull --rebase'

# ------------------------------------------------------------------------------
# 🔄 Merge & Rebase
# ------------------------------------------------------------------------------

# @name: gm
# @category: Git
# @description: Join two or more development histories together.
# @os: cross-platform
alias gm='git merge'

# @name: gma
# @category: Git
# @description: Abort the current conflict-ridden merge process cleanly.
# @os: cross-platform
alias gma='git merge --abort'

# @name: grb
# @category: Git
# @description: Reapply commits on top of another base tip.
# @os: cross-platform
alias grb='git rebase'

# @name: grba
# @category: Git
# @description: Abort the rebase operation and reset HEAD to original branch.
# @os: cross-platform
alias grba='git rebase --abort'

# @name: grbc
# @category: Git
# @description: Continue rebase after resolving conflicted hunks.
# @os: cross-platform
alias grbc='git rebase --continue'

# ------------------------------------------------------------------------------
# 📦 Stashing Helpers
# ------------------------------------------------------------------------------

# @name: gstash
# @category: Git
# @description: Save local modifications to a new stash commit.
# @os: cross-platform
alias gstash='git stash push'

# @name: gstashp
# @category: Git
# @description: Remove single stashed state from stash list and apply to working tree.
# @os: cross-platform
alias gstashp='git stash pop'

# @name: gstashl
# @category: Git
# @description: List stashes recorded in current repository.
# @os: cross-platform
alias gstashl='git stash list'

# @name: gstashd
# @category: Git
# @description: Drop the most recent stash entry from the list.
# @os: cross-platform
alias gstashd='git stash drop'

# @name: gstashs
# @category: Git
# @description: Show diff changes recorded in the most recent stash.
# @os: cross-platform
alias gstashs='git stash show --text'

# @name: gstasha
# @category: Git
# @description: Apply most recent stash without removing it from the stash stack.
# @os: cross-platform
alias gstasha='git stash apply'

# ------------------------------------------------------------------------------
# 🏷️ Tags, Remotes & Contribution Analytics
# ------------------------------------------------------------------------------

# @name: gtags
# @category: Git
# @description: List all repository tags ordered by descending creation date.
# @os: cross-platform
alias gtags='git tag --sort=-creatordate'

# @name: gremotes
# @category: Git
# @description: List all configured remote repositories with fetch and push URLs.
# @os: cross-platform
alias gremotes='git remote --verbose'

# @name: gcontributors
# @category: Git
# @description: Summarize commit counts grouped by contributor name and email.
# @os: cross-platform
alias gcontributors='git shortlog --summary --numbered --email'

# ------------------------------------------------------------------------------
# 📈 Git Log Visualizers
# ------------------------------------------------------------------------------

# @name: glog
# @category: Git
# @description: Compact visual graph of recent commits with decoration and ref names.
# @os: cross-platform
alias glog='git log --oneline --decorate --graph'

# @name: gloga
# @category: Git
# @description: Visual graph showing all branches, tags, and commits across repository.
# @os: cross-platform
alias gloga='git log --oneline --decorate --graph --all'

# @name: glast
# @category: Git
# @description: Inspect the most recent commit with changed file statistics.
# @os: cross-platform
alias glast='git log -1 HEAD --stat'

# @name: gwho
# @category: Git
# @description: Quick commit count overview per author sorted by count.
# @os: cross-platform
alias gwho='git shortlog -sn'

# @name: glogp
# @category: Git
# @description: Pretty colored commit graph with relative dates, hashes, and authors.
# @os: cross-platform
alias glogp='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'

# ------------------------------------------------------------------------------
# 🔧 Workflow & Defensive Safety Helpers
# ------------------------------------------------------------------------------

# @name: gclone
# @category: Git
# @description: Clone a repository with argument validation to prevent empty calls.
# @os: cross-platform
gclone() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: gclone <repository-url>\n' >&2
        return 2
    fi
    git clone -- "$1"
}

# @name: groot
# @category: Git
# @description: Print the absolute filesystem path of repository top-level directory.
# @os: cross-platform
groot() {
    git rev-parse --show-toplevel
}

# @name: gclean-preview
# @category: Git
# @description: Dry-run preview untracked and non-ignored files that git clean would delete.
# @os: cross-platform
alias gclean-preview='git clean -ndx'

# @name: gclean-ignored-preview
# @category: Git
# @description: Dry-run preview ignored files that git clean would delete.
# @os: cross-platform
alias gclean-ignored-preview='git clean -ndX'

# @name: gundo
# @category: Git
# @description: Undo last commit softly, retaining all modified files in staging area.
# @os: cross-platform
gundo() {
    git reset --soft HEAD~1
}

# @name: gpristine
# @category: Git
# @description: Reset repo to pristine state with explicit typed PRISTINE confirmation.
# @os: cross-platform
gpristine() {
    printf '⚠️ This will permanently discard tracked changes and remove untracked files.\n'
    git status --short
    printf 'Type PRISTINE to confirm and continue: '

    local confirmation
    read -r confirmation

    [ "$confirmation" = "PRISTINE" ] || {
        printf 'Operation cancelled.\n'
        return 1
    }

    git reset --hard HEAD && git clean -fd
}

# ------------------------------------------------------------------------------
# 🐙 GitHub CLI Helpers (Conditional)
# ------------------------------------------------------------------------------

if command -v gh >/dev/null 2>&1; then
# @name: ghpr
# @category: Git
# @description: Open the active pull request in the web browser via gh CLI.
# @os: cross-platform
alias ghpr='gh pr view --web'

# @name: ghprs
# @category: Git
# @description: List open pull requests for the current repository.
# @os: cross-platform
alias ghprs='gh pr list'

# @name: ghissues
# @category: Git
# @description: List open issues for the current repository.
# @os: cross-platform
alias ghissues='gh issue list'

# @name: ghrepo
# @category: Git
# @description: Open current repository home page in web browser.
# @os: cross-platform
alias ghrepo='gh repo view --web'

# @name: ghruns
# @category: Git
# @description: List recent GitHub Actions workflow runs.
# @os: cross-platform
alias ghruns='gh run list'

# @name: ghwatch
# @category: Git
# @description: Watch active GitHub Actions workflow run until completion.
# @os: cross-platform
alias ghwatch='gh run watch'
fi
