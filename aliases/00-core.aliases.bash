#!/usr/bin/env bash
# ==============================================================================
# 🧰 00-core.aliases.bash — Shell Navigation, Safety Guards & Core Utilities
# ==============================================================================
# Essential navigation shortcuts, defensive file operation guards, search
# utilities, archive extractors, history tweaks, and terminal helpers.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 🛠️ System Detection & Core Helpers
# ------------------------------------------------------------------------------

# @name: has
# @category: Core
# @description: Check if a command or binary exists in the current system PATH.
# @os: cross-platform
has() {
    command -v "$1" >/dev/null 2>&1
}

# Operating system identification
if [ -z "${AWESOME_ALIAS_OS:-}" ]; then
    case "$(uname -s)" in
        Darwin) export AWESOME_ALIAS_OS="macos" ;;
        Linux)  export AWESOME_ALIAS_OS="linux" ;;
        *)      export AWESOME_ALIAS_OS="other" ;;
    esac
fi

# ------------------------------------------------------------------------------
# 📂 Directory Navigation
# ------------------------------------------------------------------------------

# @name: ..
# @category: Core
# @description: Navigate one directory level up.
# @os: cross-platform
alias ..='cd ..'

# @name: ...
# @category: Core
# @description: Navigate two directory levels up.
# @os: cross-platform
alias ...='cd ../..'

# @name: ....
# @category: Core
# @description: Navigate three directory levels up.
# @os: cross-platform
alias ....='cd ../../..'

# @name: .....
# @category: Core
# @description: Navigate four directory levels up.
# @os: cross-platform
alias .....='cd ../../../..'

# @name: ......
# @category: Core
# @description: Navigate five directory levels up.
# @os: cross-platform
alias ......='cd ../../../../..'

# @name: -
# @category: Core
# @description: Switch back to the previous working directory.
# @os: cross-platform
alias -- -='cd -'

# @name: home
# @category: Core
# @description: Change to user home directory.
# @os: cross-platform
alias home='cd "${HOME}"'

# @name: root
# @category: Core
# @description: Change to root filesystem directory.
# @os: cross-platform
alias root='cd /'

# @name: mkcd
# @category: Core
# @description: Create directory path recursively and navigate directly into it.
# @os: cross-platform
mkcd() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: mkcd <directory>\n' >&2
        return 2
    fi
    mkdir -p -- "$1" && cd -- "$1"
}

# @name: croot
# @category: Core
# @description: Navigate to the root directory of the current Git repository.
# @os: cross-platform
croot() {
    local root_dir
    root_dir="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        printf 'Not inside a Git repository.\n' >&2
        return 1
    }
    cd -- "$root_dir"
}

# @name: up
# @category: Core
# @description: Navigate upward by a specified number of directory levels (default 1).
# @os: cross-platform
up() {
    local levels="${1:-1}"
    local destination=""

    case "$levels" in
        ''|*[!0-9]*)
            printf 'Usage: up [positive-integer]\n' >&2
            return 2
            ;;
    esac

    while [ "$levels" -gt 0 ]; do
        destination="../${destination}"
        levels=$((levels - 1))
    done

    cd -- "$destination"
}

# ------------------------------------------------------------------------------
# 💻 Terminal & Shell Environment
# ------------------------------------------------------------------------------

# @name: c
# @category: Core
# @description: Clear the terminal screen display.
# @os: cross-platform
alias c='clear'

# @name: cls
# @category: Core
# @description: Clear the terminal screen display and list directory contents.
# @os: cross-platform
alias cls='clear; ls'

# @name: reload
# @category: Core
# @description: Quickly source and reload the active shell configuration file.
# @os: cross-platform
alias reload='source "${HOME}/.${SHELL##*/}rc"'

# @name: reload-shell
# @category: Core
# @description: Safely reload the shell configuration profile with shell and file validation.
# @os: cross-platform
reload-shell() {
    local config
    case "${SHELL##*/}" in
        bash) config="${HOME}/.bashrc" ;;
        zsh)  config="${HOME}/.zshrc" ;;
        *)
            printf 'Unsupported shell: %s\n' "$SHELL" >&2
            return 1
            ;;
    esac

    if [ ! -f "$config" ]; then
        printf 'Configuration file not found: %s\n' "$config" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$config"
}

# @name: path
# @category: Core
# @description: Pretty-print system PATH entries one per line for inspection.
# @os: cross-platform
alias path='printf "%s\n" "${PATH//:/$'\''\n'\''}"'

# @name: now
# @category: Core
# @description: Print the current system date and 24-hour timestamp.
# @os: cross-platform
alias now='date "+%Y-%m-%d %H:%M:%S"'

# @name: week
# @category: Core
# @description: Print the current ISO calendar week number.
# @os: cross-platform
alias week='date "+%V"'

# @name: shellinfo
# @category: Core
# @description: Display active shell name, path, and version information.
# @os: cross-platform
alias shellinfo='printf "Shell: %s\nVersion: %s\n" "$SHELL" "${BASH_VERSION:-$ZSH_VERSION}"'

# ------------------------------------------------------------------------------
# 📄 File Listing & Visual Formatting
# ------------------------------------------------------------------------------

if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
# @name: ls
# @category: Core
# @description: List directory contents with colorized output (macOS BSD ls).
# @os: macos
alias ls='ls -G'

# @name: l
# @category: Core
# @description: List all files in long format with human-readable sizes and color (macOS BSD ls).
# @os: macos
alias l='ls -lahG'

# @name: ll
# @category: Core
# @description: List files in long format with human-readable sizes and color (macOS BSD ls).
# @os: macos
alias ll='ls -lhG'

# @name: la
# @category: Core
# @description: List almost all files (excluding . and ..) with color (macOS BSD ls).
# @os: macos
alias la='ls -AG'
else
# @name: ls
# @category: Core
# @description: List directory contents with colorized output (Linux GNU ls).
# @os: linux
alias ls='ls --color=auto'

# @name: l
# @category: Core
# @description: List all files in long format with human-readable sizes and color (Linux GNU ls).
# @os: linux
alias l='ls -lah --color=auto'

# @name: ll
# @category: Core
# @description: List files in long format with human-readable sizes and color (Linux GNU ls).
# @os: linux
alias ll='ls -lh --color=auto'

# @name: la
# @category: Core
# @description: List almost all files (excluding . and ..) with color (Linux GNU ls).
# @os: linux
alias la='ls -A --color=auto'
fi

# @name: ld
# @category: Core
# @description: List only directories in the current working directory.
# @os: cross-platform
alias ld='ls -ld -- */ 2>/dev/null'

# @name: tree2
# @category: Core
# @description: Display directory tree structure limited to 2 levels deep.
# @os: cross-platform
alias tree2='tree -L 2'

# @name: tree3
# @category: Core
# @description: Display directory tree structure limited to 3 levels deep.
# @os: cross-platform
alias tree3='tree -L 3'

# ------------------------------------------------------------------------------
# 🛡️ Defensive Safety Enhancements (Interactive File Operations)
# ------------------------------------------------------------------------------

# @name: cpi
# @category: Core
# @description: Copy files interactively, prompting before overwriting an existing destination.
# @os: cross-platform
alias cpi='cp -i'

# @name: mvi
# @category: Core
# @description: Move files interactively, prompting before overwriting an existing destination.
# @os: cross-platform
alias mvi='mv -i'

# @name: rmi
# @category: Core
# @description: Remove files interactively, prompting for confirmation before every deletion.
# @os: cross-platform
alias rmi='rm -i'

# @name: rmI
# @category: Core
# @description: Remove files prompting once before deleting more than 3 files or recursive targets.
# @os: cross-platform
alias rmI='rm -I'

# @name: lni
# @category: Core
# @description: Link files interactively, prompting before removing existing destination files.
# @os: cross-platform
alias lni='ln -i'

# @name: mkdirp
# @category: Core
# @description: Create directory tree including missing parent directories without complaining.
# @os: cross-platform
alias mkdirp='mkdir -p'

# Linux root protection safeguards
if [ "${AWESOME_ALIAS_OS:-}" = "linux" ]; then
# @name: rm-safe
# @category: Core
# @description: Remove files with preserve-root guard and interactive confirmation.
# @os: linux
alias rm-safe='rm -I --preserve-root'

# @name: chmod-safe
# @category: Core
# @description: Modify file permissions preventing unintended recursive operations on root.
# @os: linux
alias chmod-safe='chmod --preserve-root'

# @name: chown-safe
# @category: Core
# @description: Modify file ownership preventing unintended recursive operations on root.
# @os: linux
alias chown-safe='chown --preserve-root'

# @name: chgrp-safe
# @category: Core
# @description: Modify file group preventing unintended recursive operations on root.
# @os: linux
alias chgrp-safe='chgrp --preserve-root'
fi

# ------------------------------------------------------------------------------
# 🔍 File Search & Inspection Utilities
# ------------------------------------------------------------------------------

# @name: grep
# @category: Core
# @description: Search text with automatic color highlighting on matches.
# @os: cross-platform
alias grep='grep --color=auto'

# @name: egrep
# @category: Core
# @description: Search text using extended regular expressions with color highlighting.
# @os: cross-platform
alias egrep='grep -E --color=auto'

# @name: fgrep
# @category: Core
# @description: Search text using fixed strings with color highlighting.
# @os: cross-platform
alias fgrep='grep -F --color=auto'

# @name: countfiles
# @category: Core
# @description: Recursively count total regular files in current directory tree.
# @os: cross-platform
alias countfiles='find . -type f | wc -l'

# @name: countdirs
# @category: Core
# @description: Recursively count total directories in current directory tree.
# @os: cross-platform
alias countdirs='find . -type d | wc -l'

# @name: emptydirs
# @category: Core
# @description: Find all empty directories in current directory tree.
# @os: cross-platform
alias emptydirs='find . -type d -empty'

# @name: emptyfiles
# @category: Core
# @description: Find all empty zero-byte files in current directory tree.
# @os: cross-platform
alias emptyfiles='find . -type f -empty'

# @name: ff
# @category: Core
# @description: Case-insensitive search for files by name substring in current tree.
# @os: cross-platform
ff() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: ff <filename-pattern>\n' >&2
        return 2
    fi
    find . -type f -iname "*$1*"
}

# @name: fdirectory
# @category: Core
# @description: Case-insensitive search for directories by name substring in current tree.
# @os: cross-platform
fdirectory() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: fdirectory <directory-pattern>\n' >&2
        return 2
    fi
    find . -type d -iname "*$1*"
}

# @name: extract
# @category: Core
# @description: Universal archive extractor detecting tar, bz2, gz, xz, zst, zip, 7z, and rar.
# @os: cross-platform
extract() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: extract <archive>\n' >&2
        return 2
    fi

    local archive="$1"

    if [ ! -f "$archive" ]; then
        printf 'File not found: %s\n' "$archive" >&2
        return 1
    fi

    case "$archive" in
        *.tar.bz2|*.tbz2) tar -xjf "$archive" ;;
        *.tar.gz|*.tgz)   tar -xzf "$archive" ;;
        *.tar.xz|*.txz)   tar -xJf "$archive" ;;
        *.tar.zst)        tar --zstd -xf "$archive" ;;
        *.tar)            tar -xf "$archive" ;;
        *.bz2)            bunzip2 "$archive" ;;
        *.gz)             gunzip "$archive" ;;
        *.xz)             unxz "$archive" ;;
        *.zip)            unzip "$archive" ;;
        *.7z)             7z x "$archive" ;;
        *.rar)            unrar x "$archive" ;;
        *)
            printf 'Unsupported archive format: %s\n' "$archive" >&2
            return 1
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 🧮 Calculator & Data Encoding
# ------------------------------------------------------------------------------

# @name: calc
# @category: Core
# @description: Launch arbitrary-precision interactive calculator with standard math library.
# @os: cross-platform
alias calc='bc -l'

# @name: b64e
# @category: Core
# @description: Encode standard input or stream to base64 format.
# @os: cross-platform
alias b64e='base64'

# @name: b64d
# @category: Core
# @description: Decode base64 standard input or stream back to plaintext.
# @os: cross-platform
if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
alias b64d='base64 -D'
else
alias b64d='base64 --decode'
fi

# @name: urlencode
# @category: Core
# @description: Percent-encode string from standard input using python3.
# @os: cross-platform
alias urlencode='python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"'

# @name: urldecode
# @category: Core
# @description: Decode percent-encoded string from standard input using python3.
# @os: cross-platform
alias urldecode='python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.stdin.read().strip()))"'

# @name: sha256file
# @category: Core
# @description: Calculate SHA-256 checksum across platforms (auto-detects sha256sum or shasum).
# @os: cross-platform
sha256file() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: sha256file <file>\n' >&2
        return 2
    fi

    if has sha256sum; then
        sha256sum -- "$1"
    elif has shasum; then
        shasum -a 256 -- "$1"
    else
        printf 'Neither sha256sum nor shasum is installed.\n' >&2
        return 1
    fi
}

# ------------------------------------------------------------------------------
# 📜 History Tweaks & Productivity
# ------------------------------------------------------------------------------

# @name: h
# @category: Core
# @description: Display complete shell command execution history.
# @os: cross-platform
alias h='history'

# @name: h10
# @category: Core
# @description: Display the 10 most recent commands from history.
# @os: cross-platform
alias h10='history 10'

# @name: h20
# @category: Core
# @description: Display the 20 most recent commands from history.
# @os: cross-platform
alias h20='history 20'

# @name: h50
# @category: Core
# @description: Display the 50 most recent commands from history.
# @os: cross-platform
alias h50='history 50'

# @name: hg
# @category: Core
# @description: Filter shell command history by piped pattern search.
# @os: cross-platform
alias hg='history | grep'

# @name: hgrep
# @category: Core
# @description: Case-insensitive search through shell command execution history.
# @os: cross-platform
hgrep() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: hgrep <pattern>\n' >&2
        return 2
    fi
    history | grep -i -- "$*"
}

# Recommended history environment settings
export HISTCONTROL="ignoreboth:erasedups"
export HISTSIZE=50000
export HISTFILESIZE=100000
shopt -s histappend 2>/dev/null || true
