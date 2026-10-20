#!/usr/bin/env bash
# ==============================================================================
# 🌐 40-net.aliases.bash — Networking, Port Inspection & Diagnostic Utilities
# ==============================================================================
# Network interface diagnostics, listening port inspection, public/local IP tools,
# DNS resolution helpers, API latency profilers, TLS certificate auditors,
# and lightweight development web server functions.
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

# @name: portopen
# @category: Networking
# @description: Fast TCP port reachability probe with configurable timeout.
# @os: cross-platform
portopen() {
    if [ "$#" -lt 2 ]; then
        printf 'Usage: portopen <host> <port> [timeout-seconds]\n' >&2
        return 2
    fi

    local host="$1"
    local port="$2"
    local timeout="${3:-3}"

    if command -v nc >/dev/null 2>&1; then
        if nc -z -w "$timeout" "$host" "$port" 2>/dev/null; then
            printf '✅ Port %s on %s is OPEN\n' "$port" "$host"
            return 0
        else
            printf '❌ Port %s on %s is CLOSED or UNREACHABLE\n' "$port" "$host"
            return 1
        fi
    elif (echo > "/dev/tcp/${host}/${port}") 2>/dev/null; then
        printf '✅ Port %s on %s is OPEN\n' "$port" "$host"
        return 0
    else
        printf '❌ Port %s on %s is CLOSED or UNREACHABLE\n' "$port" "$host"
        return 1
    fi
}

# @name: tcpconns
# @category: Networking
# @description: Count and group active TCP network connections by socket state.
# @os: cross-platform
alias tcpconns='netstat -an | awk '\''/^tcp/ {print $NF}'\'' | sort | uniq -c | sort -nr'

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

# @name: publicip6
# @category: Networking
# @description: Query and display your external public IPv6 address.
# @os: cross-platform
publicip6() {
    if command -v curl >/dev/null 2>&1; then
        curl -6 --fail --silent --show-error https://api64.ipify.org 2>/dev/null || {
            printf 'IPv6 address unavailable.\n' >&2
            return 1
        }
        printf '\n'
    else
        printf 'curl is required to fetch IPv6.\n' >&2
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

# @name: gateway
# @category: Networking
# @description: Detect and print the IP address of the default gateway router.
# @os: cross-platform
gateway() {
    if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
        netstat -nr -f inet | awk '$1 == "default" {print $2; exit}'
    elif command -v ip >/dev/null 2>&1; then
        ip route show default 2>/dev/null | awk '{print $3; exit}'
    else
        netstat -rn 2>/dev/null | awk '$1 == "0.0.0.0" || $1 == "default" {print $2; exit}'
    fi
}

# @name: macaddr
# @category: Networking
# @description: Print physical MAC hardware addresses for network interfaces.
# @os: cross-platform
macaddr() {
    if [ "${AWESOME_ALIAS_OS:-}" = "macos" ]; then
        ifconfig | awk '/^[a-z0-9]+:/ {iface=$1} /ether / {print iface, $2}'
    elif command -v ip >/dev/null 2>&1; then
        ip link show | awk '/^[0-9]+:/ {iface=$2} /link\/ether/ {print iface, $2}'
    else
        ifconfig -a | awk '/^[a-z0-9]+:/ {iface=$1} /ether|HWaddr/ {print iface, $NF}'
    fi
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

# @name: digshort
# @category: Networking
# @description: Query DNS records in compact format returning only answer values.
# @os: cross-platform
alias digshort='dig +short'

# @name: digall
# @category: Networking
# @description: Query DNS records with complete multiline answers without header clutter.
# @os: cross-platform
alias digall='dig +noall +answer +multiline'

# @name: digtrace
# @category: Networking
# @description: Trace recursive DNS delegation step-by-step from root nameservers.
# @os: cross-platform
alias digtrace='dig +trace'

# @name: dnsptr
# @category: Networking
# @description: Perform reverse DNS lookup to discover hostname assigned to an IP.
# @os: cross-platform
dnsptr() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: dnsptr <ip-address>\n' >&2
        return 2
    fi
    dig -x "$1" +short
}

# @name: whoisip
# @category: Networking
# @description: Query WHOIS details summarizing organization, country, and CIDR range.
# @os: cross-platform
whoisip() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: whoisip <ip-address>\n' >&2
        return 2
    fi
    whois "$1" | grep -i -E "^(org-name|orgname|netname|descr|country|cidr|route):"
}

# ------------------------------------------------------------------------------
# 🌐 HTTP & REST API Development Shortcuts
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

# @name: httpstatus
# @category: Networking
# @description: Query and return only the HTTP response status code for target URL.
# @os: cross-platform
httpstatus() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: httpstatus <url>\n' >&2
        return 2
    fi
    curl -s -o /dev/null -w "%{http_code}\n" "$@"
}

# @name: curltime
# @category: Networking
# @description: Measure detailed HTTP timing breakdown including DNS, TCP, TLS, and TTFB.
# @os: cross-platform
curltime() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: curltime <url> [curl-options]\n' >&2
        return 2
    fi

    local url="$1"
    shift

    curl -w @- -o /dev/null -s "$@" "$url" <<'EOF'
   DNS Lookup:  %{time_namelookup}s
  TCP Connect:  %{time_connect}s
 TLS Handshake:  %{time_appconnect}s
 Pre-transfer:  %{time_pretransfer}s
Start Transfer:  %{time_starttransfer}s
--------------------------------
    Total Time:  %{time_total}s
     HTTP Code:  %{http_code}
    Speed Down:  %{speed_download} bytes/sec
EOF
}

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

# ------------------------------------------------------------------------------
# 🔐 TLS & SSL Certificate Diagnostics
# ------------------------------------------------------------------------------

# @name: tlscheck
# @category: Networking
# @description: Inspect remote server TLS certificate subject, issuer, and expiry dates.
# @os: cross-platform
tlscheck() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: tlscheck <hostname[:port]>\n' >&2
        return 2
    fi

    local host="${1%%:*}"
    local port="${1##*:}"

    if [ "$host" = "$port" ]; then
        port=443
    fi

    openssl s_client \
        -connect "${host}:${port}" \
        -servername "$host" \
        </dev/null 2>/dev/null |
        openssl x509 -noout -subject -issuer -dates -fingerprint
}

# @name: tlsexpiry
# @category: Networking
# @description: Display the exact expiration timestamp for a remote domain TLS certificate.
# @os: cross-platform
tlsexpiry() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: tlsexpiry <hostname[:port]>\n' >&2
        return 2
    fi

    local host="${1%%:*}"
    local port="${1##*:}"
    [ "$host" = "$port" ] && port=443

    local end_date
    end_date="$(openssl s_client -servername "$host" -connect "${host}:${port}" </dev/null 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)"

    if [ -z "$end_date" ]; then
        printf 'Failed to retrieve certificate from %s:%s\n' "$host" "$port" >&2
        return 1
    fi

    printf 'Certificate for %s:%s expires on: %s\n' "$host" "$port" "$end_date"
}

# @name: tlscertfile
# @category: Networking
# @description: Inspect and decode a local X.509 certificate file (.crt or .pem).
# @os: cross-platform
tlscertfile() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: tlscertfile <certificate-file>\n' >&2
        return 2
    fi

    openssl x509 -in "$1" -noout -text
}

# @name: opensslver
# @category: Networking
# @description: Display OpenSSL version and compilation build platform flags.
# @os: cross-platform
alias opensslver='openssl version -a'

# ------------------------------------------------------------------------------
# ⚡ Bandwidth & Speed Testing
# ------------------------------------------------------------------------------

# @name: downloadtest
# @category: Networking
# @description: Measure internet download throughput rate via Cloudflare edge CDN.
# @os: cross-platform
downloadtest() {
    printf 'Testing download speed via Cloudflare CDN edge...\n'
    curl -s -w 'Downloaded: %{size_download} bytes\nSpeed: %{speed_download} bytes/sec (~%{speed_download}Bps)\nTotal Time: %{time_total}s\n' -o /dev/null 'https://speed.cloudflare.com/__down?bytes=25000000'
}
