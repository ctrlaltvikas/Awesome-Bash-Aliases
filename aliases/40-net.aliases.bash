#!/usr/bin/env bash
# ==============================================================================
# 🌐 40-net.aliases.bash — Networking, Port Inspection & Diagnostic Utilities
# ==============================================================================
# Network interface diagnostics, listening port inspection, public/local IP tools,
# DNS resolution helpers, API HTTP shortcuts, and dev web server functions.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 🚪 Port Inspection & Socket Listeners
# ------------------------------------------------------------------------------

# @name: listeners
# @category: Networking
# @description: List all system processes currently listening on TCP sockets.
# @os: cross-platform
alias listeners='lsof -nP -iTCP -sTCP:LISTEN'

# @name: connections
# @category: Networking
# @description: List all active internet network socket connections.
# @os: cross-platform
alias connections='lsof -nP -i'

# @name: portcheck
# @category: Networking
# @description: Identify processes listening on a specific TCP port number.
# @os: cross-platform
portcheck() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: portcheck <port-number>\n' >&2
        return 2
    fi
    lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

# @name: killport
# @category: Networking
# @description: Identify and interactively terminate process listening on given TCP port.
# @os: cross-platform
killport() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: killport <port-number>\n' >&2
        return 2
    fi

    local pids
    pids="$(lsof -tiTCP:"$1" -sTCP:LISTEN)"

    if [ -z "$pids" ]; then
        printf 'Nothing is listening on port %s.\n' "$1"
        return 0
    fi

    printf 'Process(es) listening on port %s:\n' "$1"
    lsof -nP -iTCP:"$1" -sTCP:LISTEN
    printf '\nPIDs to terminate: %s\n' "$pids"
    printf 'Terminate these processes? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # shellcheck disable=SC2086
            kill $pids
            printf 'Sent SIGTERM to process(es).\n'
            ;;
        *)
            printf 'Operation cancelled.\n'
            ;;
    esac
}

# @name: netstat-listen
# @category: Networking
# @description: Query listening TCP/UDP ports using netstat across platforms.
# @os: cross-platform
alias netstat-listen='netstat -tuln 2>/dev/null || netstat -an | grep LISTEN'

# ------------------------------------------------------------------------------
# 🌍 IP Address & Interface Diagnostics
# ------------------------------------------------------------------------------

# @name: publicip
# @category: Networking
# @description: Query and display your external public IPv4 address.
# @os: cross-platform
publicip() {
    if command -v curl >/dev/null 2>&1; then
        curl --fail --silent --show-error https://api.ipify.org
        printf '\n'
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://api.ipify.org
        printf '\n'
    else
        printf 'curl or wget is required to fetch public IP.\n' >&2
        return 1
    fi
}

# @name: localip
# @category: Networking
# @description: Query and display primary internal LAN IP address.
# @os: cross-platform
localip() {
    if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
        ipconfig getifaddr en0 2>/dev/null ||
            ipconfig getifaddr en1 2>/dev/null ||
            ipconfig getifaddr en2 2>/dev/null
    elif command -v hostname >/dev/null 2>&1; then
        hostname -I 2>/dev/null | awk '{print $1}'
    elif command -v ip >/dev/null 2>&1; then
        ip -br addr show 2>/dev/null | awk '$1 !~ /^lo/ && $2 ~ /UP/ {print $3}' | cut -d/ -f1 | head -1
    else
        printf 'Unable to determine local IP address.\n' >&2
        return 1
    fi
}

# @name: ips
# @category: Networking
# @description: Display all configured network interfaces with their IP addresses.
# @os: cross-platform
ips() {
    if command -v ip >/dev/null 2>&1; then
        ip -br addr
    else
        ifconfig -a | awk '/^[a-z0-9]+[:]/ {iface=$1} /inet / {print iface, $2}'
    fi
}

# @name: myip
# @category: Networking
# @description: Print clean formatted summary of both internal and external IP addresses.
# @os: cross-platform
myip() {
    printf '🏠 Local IP:  %s\n' "$(localip)"
    printf '🌍 Public IP: %s\n' "$(publicip 2>/dev/null || printf 'unavailable')"
}

# @name: routeinfo
# @category: Networking
# @description: Display operating system IP routing table entries.
# @os: cross-platform
alias routeinfo='ip route 2>/dev/null || netstat -rn'

# ------------------------------------------------------------------------------
# 📡 DNS Lookup & Network Troubleshooting Utilities
# ------------------------------------------------------------------------------

# @name: dnsinfo
# @category: Networking
# @description: Inspect local system DNS name server resolver configuration.
# @os: cross-platform
alias dnsinfo='cat /etc/resolv.conf'

# @name: hostsfile
# @category: Networking
# @description: Inspect system local static hostname mappings (/etc/hosts).
# @os: cross-platform
alias hostsfile='cat /etc/hosts'

# @name: ping5
# @category: Networking
# @description: Send exactly 5 ICMP echo requests to target host and terminate.
# @os: cross-platform
alias ping5='ping -c 5'

# @name: pingdns
# @category: Networking
# @description: Verify internet reachability by pinging Cloudflare Public DNS (1.1.1.1).
# @os: cross-platform
alias pingdns='ping -c 5 1.1.1.1'

# @name: flushdns
# @category: Networking
# @description: Flush the local operating system DNS resolver cache.
# @os: cross-platform
flushdns() {
    if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
        sudo dscacheutil -flushcache
        sudo killall -HUP mDNSResponder
        printf '✅ macOS DNS cache flushed successfully.\n'
    elif command -v resolvectl >/dev/null 2>&1; then
        sudo resolvectl flush-caches
        printf '✅ systemd-resolved DNS cache flushed successfully.\n'
    elif command -v systemd-resolve >/dev/null 2>&1; then
        sudo systemd-resolve --flush-caches
        printf '✅ systemd-resolve DNS cache flushed successfully.\n'
    elif [ -f /etc/init.d/nscd ]; then
        sudo /etc/init.d/nscd restart
        printf '✅ nscd DNS cache restarted successfully.\n'
    else
        printf 'Unable to detect DNS cache daemon to flush.\n' >&2
        return 1
    fi
}

# ------------------------------------------------------------------------------
# 🌐 HTTP & API Development Shortcuts
# ------------------------------------------------------------------------------

# @name: headers
# @category: Networking
# @description: Fetch and display only HTTP response headers for target URL.
# @os: cross-platform
alias headers='curl --head'

# @name: curlv
# @category: Networking
# @description: Fetch URL with verbose curl debugging output enabled.
# @os: cross-platform
alias curlv='curl --verbose'

# @name: jsonheader
# @category: Networking
# @description: Send HTTP request with Accept application/json request header.
# @os: cross-platform
alias jsonheader='curl -H "Accept: application/json"'

# @name: serve
# @category: Networking
# @description: Spin up local development HTTP server bound to loopback 127.0.0.1.
# @os: cross-platform
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"

    if ! command -v python3 >/dev/null 2>&1; then
        printf 'python3 is required to run local web server.\n' >&2
        return 1
    fi

    printf '🚀 Serving "%s" at http://127.0.0.1:%s (loopback only)\n' "$directory" "$port"
    python3 -m http.server "$port" \
        --bind 127.0.0.1 \
        --directory "$directory"
}

# @name: serve-lan
# @category: Networking
# @description: Spin up development HTTP server bound to 0.0.0.0 for LAN access.
# @os: cross-platform
serve-lan() {
    local port="${1:-8000}"
    local directory="${2:-.}"

    if ! command -v python3 >/dev/null 2>&1; then
        printf 'python3 is required to run local web server.\n' >&2
        return 1
    fi

    printf '🌐 Serving "%s" at http://0.0.0.0:%s (accessible on LAN)\n' "$directory" "$port"
    python3 -m http.server "$port" \
        --bind 0.0.0.0 \
        --directory "$directory"
}
