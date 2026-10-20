#!/usr/bin/env bash
# ==============================================================================
# 🖥️ 50-sys.aliases.bash — System Administration, Resource Profiling & Logs
# ==============================================================================
# Disk capacity analysis, memory and CPU profiling, process search & termination,
# systemd service inspection, journal log tails, and power operation guards.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 💾 Disk Usage & Storage Analysis
# ------------------------------------------------------------------------------

# @name: dfh
# @category: System
# @description: Display disk filesystem space usage with human-readable units.
# @os: cross-platform
alias dfh='df -h'

# @name: dfi
# @category: System
# @description: Display inode usage and availability across mounted filesystems.
# @os: cross-platform
alias dfi='df -i'

# @name: usage
# @category: System
# @description: Calculate and display total disk usage of current directory.
# @os: cross-platform
alias usage='du -sh .'

# @name: biggest
# @category: System
# @description: Identify top 20 largest files and folders in current directory.
# @os: cross-platform
alias biggest='du -sh ./* 2>/dev/null | sort -h | tail -20'

if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
# @name: du1
# @category: System
# @description: Display disk usage for immediate subdirectories (depth 1, BSD du).
# @os: macos
alias du1='du -h -d 1'
else
# @name: du1
# @category: System
# @description: Display disk usage for immediate subdirectories (depth 1, GNU du).
# @os: linux
alias du1='du -h --max-depth=1'

# @name: partitions
# @category: System
# @description: Display physical storage partitions excluding virtual and tmpfs mounts.
# @os: linux
alias partitions='df -hT -x tmpfs -x devtmpfs'
fi

if command -v ncdu >/dev/null 2>&1; then
# @name: disk
# @category: System
# @description: Launch interactive ncurses disk usage analyzer.
# @os: cross-platform
alias disk='ncdu'
fi

# ------------------------------------------------------------------------------
# 📊 CPU, Memory & Resource Profiling
# ------------------------------------------------------------------------------

# @name: processes
# @category: System
# @description: List all active processes running across the operating system.
# @os: cross-platform
alias processes='ps aux'

# @name: uptimeh
# @category: System
# @description: Show system uptime and current load averages.
# @os: cross-platform
alias uptimeh='uptime'

# @name: load
# @category: System
# @description: Print system uptime, user count, and load averages.
# @os: cross-platform
alias load='uptime'

# @name: kernel
# @category: System
# @description: Print complete operating system kernel name, version, and architecture.
# @os: cross-platform
alias kernel='uname -a'

if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
# @name: mem
# @category: System
# @description: Display macOS virtual memory page statistics.
# @os: macos
alias mem='vm_stat'

# @name: psmem
# @category: System
# @description: List processes sorted descending by physical memory usage (macOS).
# @os: macos
alias psmem='ps aux | sort -nrk 4'

# @name: psmem10
# @category: System
# @description: Display top 10 memory-consuming processes (macOS).
# @os: macos
alias psmem10='ps aux | sort -nrk 4 | head -10'

# @name: pscpu
# @category: System
# @description: List processes sorted descending by CPU utilization (macOS).
# @os: macos
alias pscpu='ps aux | sort -nrk 3'

# @name: pscpu10
# @category: System
# @description: Display top 10 CPU-consuming processes (macOS).
# @os: macos
alias pscpu10='ps aux | sort -nrk 3 | head -10'
else
# @name: mem
# @category: System
# @description: Display total, used, and free system memory with human-readable units.
# @os: linux
alias mem='free -h'

# @name: psmem
# @category: System
# @description: List processes sorted descending by physical memory percentage (Linux).
# @os: linux
alias psmem='ps aux --sort=-%mem'

# @name: psmem10
# @category: System
# @description: Display top 10 memory-consuming processes (Linux).
# @os: linux
alias psmem10='ps aux --sort=-%mem | head -11'

# @name: pscpu
# @category: System
# @description: List processes sorted descending by CPU percentage (Linux).
# @os: linux
alias pscpu='ps aux --sort=-%cpu'

# @name: pscpu10
# @category: System
# @description: Display top 10 CPU-consuming processes (Linux).
# @os: linux
alias pscpu10='ps aux --sort=-%cpu | head -11'
fi

# ------------------------------------------------------------------------------
# 🔍 Process Search & Guarded Termination
# ------------------------------------------------------------------------------

# @name: psgrep
# @category: System
# @description: Search process list by pattern without matching grep process itself.
# @os: cross-platform
psgrep() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: psgrep <pattern>\n' >&2
        return 2
    fi
    ps aux | grep -i -- "$*" | grep -v grep
}

# @name: pskill
# @category: System
# @description: Search processes by pattern and interactively confirm termination.
# @os: cross-platform
pskill() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: pskill <process-name-pattern>\n' >&2
        return 2
    fi

    local pattern="$*"
    local matches
    matches="$(ps aux | grep -i -- "$pattern" | grep -v grep | grep -v "pskill $pattern")"

    if [ -z "$matches" ]; then
        printf 'No matching processes found for "%s".\n' "$pattern"
        return 0
    fi

    printf 'Matching processes:\n%s\n\n' "$matches"

    local pids
    pids="$(printf '%s\n' "$matches" | awk '{print $2}')"

    printf 'PIDs to kill: %s\n' "$(printf '%s' "$pids" | tr '\n' ' ')"
    printf 'Terminate these processes? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # shellcheck disable=SC2086
            kill $pids
            printf 'Sent SIGTERM signal to matching process(es).\n'
            ;;
        *)
            printf 'Operation cancelled.\n'
            ;;
    esac
}

# ------------------------------------------------------------------------------
# 🖥️ Linux System & Hardware Information (Conditional)
# ------------------------------------------------------------------------------

if [ "${AWESOME_ALIAS_OS:-}" = "linux" ]; then
# @name: cpuinfo
# @category: System
# @description: Display detailed CPU architecture and core information.
# @os: linux
alias cpuinfo='lscpu'

# @name: blockdevices
# @category: System
# @description: List block devices and their associated filesystems with UUIDs.
# @os: linux
alias blockdevices='lsblk -f'

# @name: pci
# @category: System
# @description: List all PCI bus devices and hardware controllers.
# @os: linux
alias pci='lspci'

# @name: usb
# @category: System
# @description: List all USB controllers and connected USB devices.
# @os: linux
alias usb='lsusb'

# @name: mounts
# @category: System
# @description: List mounted filesystems in clean hierarchical tree representation.
# @os: linux
alias mounts='findmnt'

# @name: journalerrors
# @category: System
# @description: Show system errors and critical alerts logged during current boot.
# @os: linux
alias journalerrors='journalctl -p err..alert -b'

# @name: failedservices
# @category: System
# @description: List systemd service units that entered a failed state.
# @os: linux
alias failedservices='systemctl --failed'

# @name: services
# @category: System
# @description: List all loaded and active systemd services.
# @os: linux
alias services='systemctl --type=service'
fi

if command -v nvidia-smi >/dev/null 2>&1; then
# @name: gpu
# @category: System
# @description: Query NVIDIA GPU status, memory consumption, and thermals.
# @os: cross-platform
alias gpu='nvidia-smi'

# @name: gpuwatch
# @category: System
# @description: Monitor NVIDIA GPU utilization continuously every 2 seconds.
# @os: cross-platform
alias gpuwatch='watch -n 2 nvidia-smi'
fi

# ------------------------------------------------------------------------------
# 📒 Systemd Service & Journal Logs (Conditional)
# ------------------------------------------------------------------------------

if command -v systemctl >/dev/null 2>&1; then
# @name: sc
# @category: System
# @description: Control the systemd system and service manager.
# @os: linux
alias sc='systemctl'

# @name: scu
# @category: System
# @description: Manage systemd services belonging to the current user.
# @os: linux
alias scu='systemctl --user'

# @name: jc
# @category: System
# @description: Query systemd journal system logs.
# @os: linux
alias jc='journalctl'

# @name: jcf
# @category: System
# @description: Follow and stream systemd journal logs live.
# @os: linux
alias jcf='journalctl --follow'

# @name: jcb
# @category: System
# @description: View systemd journal logs recorded since the current boot.
# @os: linux
alias jcb='journalctl --boot'

# @name: jcxe
# @category: System
# @description: Show journal logs with catalog explanations and newest lines first.
# @os: linux
alias jcxe='journalctl -xe'

# @name: svcstatus
# @category: System
# @description: Inspect running status and recent logs for specified service unit.
# @os: linux
svcstatus() {
    systemctl status "$@"
}

# @name: svclogs
# @category: System
# @description: View and filter journalctl logs for a specific systemd unit.
# @os: linux
svclogs() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: svclogs <service-name> [journalctl-options]\n' >&2
        return 2
    fi

    local service="$1"
    shift
    journalctl -u "$service" "$@"
}
fi

# ------------------------------------------------------------------------------
# ⚡ Safe Power & Reboot Operations
# ------------------------------------------------------------------------------

# @name: sys-reboot
# @category: System
# @description: Explicit reboot of machine requiring sudo elevation.
# @os: cross-platform
alias sys-reboot='sudo systemctl reboot'

# @name: sys-poweroff
# @category: System
# @description: Explicit power off and shutdown of machine requiring sudo elevation.
# @os: cross-platform
alias sys-poweroff='sudo systemctl poweroff'

# @name: sys-suspend
# @category: System
# @description: Explicit suspension of system state into low-power sleep mode.
# @os: cross-platform
alias sys-suspend='sudo systemctl suspend'
