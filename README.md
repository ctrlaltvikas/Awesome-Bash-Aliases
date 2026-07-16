# Awesome Bash Aliases

A carefully curated collection of safe, practical, and modern shell aliases and functions for developers, DevOps engineers, platform engineers, system administrators, solution architects, and Linux/macOS power users.

The project focuses on:

* Everyday terminal productivity
* Git and software-development workflows
* Docker and container management
* Kubernetes operations
* Networking and troubleshooting
* Linux and macOS system administration
* Infrastructure as Code
* Cloud-native development
* Safe and predictable command behaviour

> **Principle:** Save keystrokes without hiding important behaviour or making destructive operations dangerously easy.

Website: `https://vikaskyadav.github.io/awesome-bash-alias/`

---

## Why This Project?

Shell aliases are easy to create but difficult to maintain well.

A reliable collection should:

1. Avoid duplicate or conflicting aliases.
2. Work across Linux and macOS wherever possible.
3. Use functions when arguments or validation are required.
4. Avoid silently destructive commands.
5. Detect optional tools before configuring them.
6. Preserve tab completion.
7. Clearly separate safe shortcuts from advanced administrative operations.
8. Remain understandable even months after installation.

---

## Supported Shells

The primary target is:

* Bash 4+
* Bash 5+
* Zsh, where syntax is compatible

Some completion settings are shell-specific and are stored separately.

---

## Repository Structure

```text
awesome-bash-alias/
├── README.md
├── aliases.sh
├── install.sh
├── uninstall.sh
├── completions/
│   ├── bash.sh
│   └── zsh.sh
├── modules/
│   ├── core.sh
│   ├── navigation.sh
│   ├── files.sh
│   ├── git.sh
│   ├── docker.sh
│   ├── kubernetes.sh
│   ├── networking.sh
│   ├── system.sh
│   ├── packages.sh
│   ├── development.sh
│   ├── infrastructure.sh
│   ├── cloud.sh
│   └── macos.sh
├── optional/
│   ├── modern-cli.sh
│   └── dangerous.sh
└── tests/
    └── aliases.bats
```

This modular structure allows users to enable only the sections they need.

---

# Installation

## Quick Installation

```bash
git clone https://github.com/vikaskyadav/awesome-bash-alias.git \
  "${HOME}/.awesome-bash-alias"

printf '\n# Awesome Bash Aliases\n' >> "${HOME}/.bashrc"
printf 'source "$HOME/.awesome-bash-alias/aliases.sh"\n' >> "${HOME}/.bashrc"

source "${HOME}/.bashrc"
```

For Zsh:

```bash
printf '\n# Awesome Bash Aliases\n' >> "${HOME}/.zshrc"
printf 'source "$HOME/.awesome-bash-alias/aliases.sh"\n' >> "${HOME}/.zshrc"

source "${HOME}/.zshrc"
```

Before installing, users should review the aliases and remove any that conflict with their existing configuration.

---

# Configuration Principles

## Aliases versus Functions

Use an alias for straightforward command substitution:

```bash
alias gs='git status --short --branch'
```

Use a function when:

* Arguments are accepted.
* Validation is required.
* Multiple commands are executed.
* Quoting is important.
* Behaviour depends on the operating system.

Example:

```bash
mkcd() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: mkcd <directory>\n' >&2
        return 2
    fi

    mkdir -p -- "$1" && cd -- "$1"
}
```

---

# Core Configuration

## Helpers

```bash
# Return success when a command is installed.
has() {
    command -v "$1" >/dev/null 2>&1
}

# Operating-system detection.
case "$(uname -s)" in
    Darwin)
        export AWESOME_ALIAS_OS="macos"
        ;;
    Linux)
        export AWESOME_ALIAS_OS="linux"
        ;;
    *)
        export AWESOME_ALIAS_OS="other"
        ;;
esac
```

---

# Terminal and Shell

```bash
alias c='clear'
alias cls='clear; ls'
alias reload='source "${HOME}/.${SHELL##*/}rc"'
alias path='printf "%s\n" "${PATH//:/$'\''\n'\''}"'
alias now='date "+%Y-%m-%d %H:%M:%S"'
alias week='date "+%V"'
alias shellinfo='printf "Shell: %s\nVersion: %s\n" "$SHELL" "$BASH_VERSION"'
```

The `reload` alias works for common Bash and Zsh configurations, provided the corresponding configuration file exists.

A safer function is:

```bash
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
```

---

# Navigation

Use one consistent hierarchy rather than defining several conflicting alternatives.

```bash
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

alias -- -='cd -'
alias home='cd "${HOME}"'
alias root='cd /'
```

Useful directory functions:

```bash
mkcd() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: mkcd <directory>\n' >&2
        return 2
    fi

    mkdir -p -- "$1" && cd -- "$1"
}

croot() {
    local root

    root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        printf 'Not inside a Git repository.\n' >&2
        return 1
    }

    cd -- "$root"
}

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
```

Examples:

```bash
mkcd new-project
up 3
croot
```

---

# File Listing

Linux and macOS ship different implementations of several core utilities. Configure them separately.

```bash
if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
    alias ls='ls -G'
    alias l='ls -lahG'
    alias ll='ls -lhG'
    alias la='ls -AG'
else
    alias ls='ls --color=auto'
    alias l='ls -lah --color=auto'
    alias ll='ls -lh --color=auto'
    alias la='ls -A --color=auto'
fi
```

Additional listing commands:

```bash
alias ld='ls -ld -- */ 2>/dev/null'
alias tree2='tree -L 2'
alias tree3='tree -L 3'
```

Do not configure `ls='ls -a'`; doing so unexpectedly changes the behaviour of every `ls` invocation and makes scripts or copied commands harder to reason about.

---

# Safe File Operations

Overriding standard commands can sometimes break scripts or surprise experienced users. Therefore, explicit safe variants are preferable.

```bash
alias cpi='cp -i'
alias mvi='mv -i'
alias rmi='rm -i'
alias rmI='rm -I'
alias lni='ln -i'
alias mkdirp='mkdir -p'
```

Avoid globally aliasing `rm`, `cp`, or `mv` unless users deliberately opt in.

Optional interactive protection:

```bash
# Enable only after reviewing the implications.
# alias cp='cp -i'
# alias mv='mv -i'
# alias rm='rm -I'
```

Linux-specific root protection:

```bash
if [ "$AWESOME_ALIAS_OS" = "linux" ]; then
    alias rm-safe='rm -I --preserve-root'
    alias chmod-safe='chmod --preserve-root'
    alias chown-safe='chown --preserve-root'
    alias chgrp-safe='chgrp --preserve-root'
fi
```

---

# File Search and Inspection

```bash
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'

alias countfiles='find . -type f | wc -l'
alias countdirs='find . -type d | wc -l'
alias emptydirs='find . -type d -empty'
alias emptyfiles='find . -type f -empty'
```

Functions:

```bash
ff() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: ff <filename-pattern>\n' >&2
        return 2
    fi

    find . -type f -iname "*$1*"
}

fdirectory() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: fdirectory <directory-pattern>\n' >&2
        return 2
    fi

    find . -type d -iname "*$1*"
}

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
```

---

# Disk Usage

GNU and BSD `du` use different depth options.

```bash
alias dfh='df -h'
alias dfi='df -i'
alias usage='du -sh .'
alias biggest='du -sh ./* 2>/dev/null | sort -h | tail -20'

if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
    alias du1='du -h -d 1'
else
    alias du1='du -h --max-depth=1'
    alias partitions='df -hT -x tmpfs -x devtmpfs'
fi
```

When available:

```bash
if has ncdu; then
    alias disk='ncdu'
fi
```

---

# Calculator and Encoding

```bash
alias calc='bc -l'
alias sha256='sha256sum'
alias b64e='base64'
alias urlencode='python3 -c "import sys,urllib.parse; print(urllib.parse.quote(sys.stdin.read().strip()))"'
```

Cross-platform SHA-256 function:

```bash
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
```

---

# History

```bash
alias h='history'
alias h10='history 10'
alias h20='history 20'
alias h50='history 50'
alias hg='history | grep'
```

More reliable history search:

```bash
hgrep() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: hgrep <pattern>\n' >&2
        return 2
    fi

    history | grep -i -- "$*"
}
```

Recommended shell settings:

```bash
export HISTCONTROL="ignoreboth:erasedups"
export HISTSIZE=50000
export HISTFILESIZE=100000

shopt -s histappend 2>/dev/null || true
```

Avoid storing secrets directly in shell commands because they may be retained in shell history, terminal logs, audit systems, or process information.

---

# Git

## Everyday Git

```bash
alias g='git'
alias gs='git status --short --branch'
alias gst='git status'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'

alias gd='git diff'
alias gds='git diff --staged'
alias gdw='git diff --word-diff'

alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'

alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gcan='git commit --amend --no-edit'

alias gsw='git switch'
alias gswc='git switch --create'
alias grs='git restore'
alias grss='git restore --staged'

alias gco='git checkout'
alias gcb='git checkout -b'

alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gp='git push'
alias gpu='git push --set-upstream origin HEAD'
alias gpf='git push --force-with-lease'
alias gl='git pull'
alias glr='git pull --rebase'

alias gm='git merge'
alias gma='git merge --abort'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'

alias gstash='git stash push'
alias gstashp='git stash pop'
alias gstashl='git stash list'

alias gtags='git tag --sort=-creatordate'
alias gremotes='git remote --verbose'
alias gcontributors='git shortlog --summary --numbered --email'
```

## Git Logs

```bash
alias glog='git log --oneline --decorate --graph'
alias gloga='git log --oneline --decorate --graph --all'
alias glast='git log -1 HEAD --stat'
alias gwho='git shortlog -sn'
```

## Git Functions

```bash
gclone() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: gclone <repository-url>\n' >&2
        return 2
    fi

    git clone -- "$1"
}

groot() {
    git rev-parse --show-toplevel
}

gclean-preview() {
    git clean -ndx
}

gclean-ignored-preview() {
    git clean -ndX
}

gundo() {
    git reset --soft HEAD~1
}

gpristine() {
    printf 'This will discard tracked changes and remove untracked files.\n'
    git status --short
    printf 'Type PRISTINE to continue: '

    local confirmation
    read -r confirmation

    [ "$confirmation" = "PRISTINE" ] || {
        printf 'Cancelled.\n'
        return 1
    }

    git reset --hard HEAD && git clean -fd
}
```

Do not provide aliases such as `nah`, `gclean`, or other one-word commands that silently destroy work.

---

# GitHub CLI

Enabled only when GitHub CLI is installed:

```bash
if has gh; then
    alias ghpr='gh pr view --web'
    alias ghprs='gh pr list'
    alias ghissues='gh issue list'
    alias ghrepo='gh repo view --web'
    alias ghruns='gh run list'
    alias ghwatch='gh run watch'
fi
```

---

# Docker

Docker commands should normally run without `sudo`. Users should configure Docker according to their operating system and security model.

## Container and Image Commands

```bash
if has docker; then
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps --all'
    alias di='docker images'
    alias dimg='docker image ls'
    alias dvol='docker volume ls'
    alias dnet='docker network ls'
    alias dinfo='docker info'
    alias dver='docker version'

    alias dlog='docker logs'
    alias dlogf='docker logs --follow --tail 200'
    alias dstats='docker stats'
    alias dtop='docker top'
    alias dinspect='docker inspect'

    alias dbuild='docker build'
    alias dbuildx='docker buildx build'
    alias dpull='docker pull'
    alias dpush='docker push'

    alias dprune-preview='docker system df'
fi
```

## Docker Functions

```bash
dsh() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: dsh <container> [command]\n' >&2
        return 2
    fi

    local container="$1"
    shift

    if [ "$#" -gt 0 ]; then
        docker exec -it "$container" "$@"
    elif docker exec "$container" test -x /bin/bash 2>/dev/null; then
        docker exec -it "$container" /bin/bash
    else
        docker exec -it "$container" /bin/sh
    fi
}

drun() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: drun <image> [command]\n' >&2
        return 2
    fi

    docker run --rm -it "$@"
}

dip() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: dip <container>\n' >&2
        return 2
    fi

    docker inspect \
        --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
        "$1"
}

dstop-all() {
    local containers
    containers="$(docker ps -q)"

    if [ -z "$containers" ]; then
        printf 'No running containers.\n'
        return 0
    fi

    printf '%s\n' "$containers"
    printf 'Stop all running containers? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # Intentional word splitting of container IDs.
            # shellcheck disable=SC2086
            docker stop $containers
            ;;
        *)
            printf 'Cancelled.\n'
            ;;
    esac
}

dprune() {
    docker system df
    printf 'Run Docker system prune? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            docker system prune
            ;;
        *)
            printf 'Cancelled.\n'
            ;;
    esac
}
```

Avoid making `docker system prune -af`, deletion of every container, or deletion of every image available through an unguarded short alias.

---

# Docker Compose

Modern Docker installations use the Compose CLI plugin:

```bash
if has docker && docker compose version >/dev/null 2>&1; then
    alias dc='docker compose'
    alias dcu='docker compose up'
    alias dcud='docker compose up --detach'
    alias dcub='docker compose up --detach --build'
    alias dcd='docker compose down'
    alias dcdv='docker compose down --volumes'
    alias dcps='docker compose ps'
    alias dcl='docker compose logs'
    alias dclf='docker compose logs --follow --tail 200'
    alias dcb='docker compose build'
    alias dcpull='docker compose pull'
    alias dcconfig='docker compose config'
    alias dcrestart='docker compose restart'
fi
```

`dcdv` removes project volumes and should therefore be used deliberately.

---

# Kubernetes

## Core Commands

```bash
if has kubectl; then
    alias k='kubectl'

    alias kg='kubectl get'
    alias kd='kubectl describe'
    alias ka='kubectl apply -f'
    alias kdel='kubectl delete'
    alias ke='kubectl edit'

    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods --all-namespaces'
    alias kgpw='kubectl get pods --watch'
    alias kgd='kubectl get deployments'
    alias kgs='kubectl get services'
    alias kgi='kubectl get ingress'
    alias kgn='kubectl get nodes'
    alias kgns='kubectl get namespaces'
    alias kgcm='kubectl get configmaps'
    alias kgsec='kubectl get secrets'
    alias kgpv='kubectl get persistentvolumes'
    alias kgpvc='kubectl get persistentvolumeclaims'

    alias kdp='kubectl describe pod'
    alias kdd='kubectl describe deployment'
    alias kdn='kubectl describe node'

    alias kl='kubectl logs'
    alias klf='kubectl logs --follow --tail=200'
    alias kexec='kubectl exec -it'
    alias ktop='kubectl top'
    alias ktopn='kubectl top nodes'
    alias ktopp='kubectl top pods'

    alias kctx='kubectl config current-context'
    alias kctxs='kubectl config get-contexts'
    alias kns='kubectl config view --minify --output "jsonpath={..namespace}"'

    alias kev='kubectl get events --sort-by=.metadata.creationTimestamp'
    alias kroll='kubectl rollout status'
    alias krestart='kubectl rollout restart'
    alias khistory='kubectl rollout history'
    alias kundoroll='kubectl rollout undo'

    alias kapi='kubectl api-resources'
    alias kexplain='kubectl explain'
    alias kdiff='kubectl diff -f'
fi
```

## Kubernetes Functions

```bash
kuse() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: kuse <context>\n' >&2
        return 2
    fi

    kubectl config use-context "$1"
}

knamespace() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: knamespace <namespace>\n' >&2
        return 2
    fi

    kubectl config set-context \
        --current \
        --namespace="$1"
}

kpf() {
    if [ "$#" -lt 2 ]; then
        printf 'Usage: kpf <resource> <local-port:remote-port> [additional-options]\n' >&2
        return 2
    fi

    kubectl port-forward "$@"
}

kdebug() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: kdebug <pod> [debug-image]\n' >&2
        return 2
    fi

    local pod="$1"
    local image="${2:-busybox:1.36}"

    kubectl debug -it "$pod" --image="$image"
}
```

Do not create an alias that deletes every Kubernetes resource or namespace. Cluster context and namespace should remain visible and deliberate.

---

# Helm

```bash
if has helm; then
    alias h='helm'
    alias hls='helm list'
    alias hlsa='helm list --all-namespaces'
    alias hrepo='helm repo list'
    alias hrepou='helm repo update'
    alias hsearch='helm search repo'
    alias hstatus='helm status'
    alias hhistory='helm history'
    alias hrollback='helm rollback'
    alias htemplate='helm template'
    alias hlint='helm lint'
fi
```

Because `h` is commonly used for shell history, projects should choose either:

```bash
alias h='history'
```

or:

```bash
alias h='helm'
```

Do not define both.

A less ambiguous Helm prefix is recommended:

```bash
alias hm='helm'
alias hmls='helm list'
alias hmlsa='helm list --all-namespaces'
```

---

# Terraform and OpenTofu

```bash
if has terraform; then
    alias tf='terraform'
    alias tfi='terraform init'
    alias tff='terraform fmt'
    alias tffr='terraform fmt -recursive'
    alias tfv='terraform validate'
    alias tfp='terraform plan'
    alias tfa='terraform apply'
    alias tfo='terraform output'
    alias tfs='terraform show'
    alias tfw='terraform workspace'
    alias tfwl='terraform workspace list'
    alias tfstate='terraform state list'
fi

if has tofu; then
    alias tofu-init='tofu init'
    alias tofu-fmt='tofu fmt -recursive'
    alias tofu-validate='tofu validate'
    alias tofu-plan='tofu plan'
    alias tofu-apply='tofu apply'
fi
```

Do not alias `terraform destroy` or `tofu destroy` to a short, easily mistyped command.

---

# Ansible

```bash
if has ansible; then
    alias av='ansible --version'
    alias ai='ansible-inventory'
    alias aigr='ansible-inventory --graph'
    alias ap='ansible-playbook'
    alias apcheck='ansible-playbook --check --diff'
    alias alint='ansible-lint'
fi
```

---

# Networking

## General Commands

```bash
alias ping5='ping -c 5'
alias pingdns='ping -c 5 1.1.1.1'
alias routeinfo='ip route 2>/dev/null || netstat -rn'
alias dnsinfo='cat /etc/resolv.conf'
alias listeners='lsof -nP -iTCP -sTCP:LISTEN'
alias connections='lsof -nP -i'
alias hostsfile='cat /etc/hosts'
```

Avoid aliasing the standard `ping` command globally to `ping -c 5`, because users may expect normal continuous ping behaviour.

## Public IP

```bash
publicip() {
    if has curl; then
        curl --fail --silent --show-error https://api.ipify.org
        printf '\n'
    elif has wget; then
        wget -qO- https://api.ipify.org
        printf '\n'
    else
        printf 'curl or wget is required.\n' >&2
        return 1
    fi
}
```

## Local IP

```bash
localip() {
    if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
        ipconfig getifaddr en0 2>/dev/null ||
            ipconfig getifaddr en1 2>/dev/null
    elif has hostname; then
        hostname -I 2>/dev/null | awk '{print $1}'
    else
        printf 'Unable to determine local IP address.\n' >&2
        return 1
    fi
}
```

## Port Inspection

```bash
portcheck() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: portcheck <port>\n' >&2
        return 2
    fi

    lsof -nP -iTCP:"$1" -sTCP:LISTEN
}

killport() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: killport <port>\n' >&2
        return 2
    fi

    local pids
    pids="$(lsof -tiTCP:"$1" -sTCP:LISTEN)"

    if [ -z "$pids" ]; then
        printf 'Nothing is listening on port %s.\n' "$1"
        return 0
    fi

    printf 'Processes listening on port %s:\n%s\n' "$1" "$pids"
    printf 'Terminate these processes? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # Intentional splitting of PID list.
            # shellcheck disable=SC2086
            kill $pids
            ;;
        *)
            printf 'Cancelled.\n'
            ;;
    esac
}
```

---

# HTTP and API Development

```bash
alias headers='curl --head'
alias curlv='curl --verbose'
alias jsonheader='curl -H "Accept: application/json"'
```

Local development server:

```bash
serve() {
    local port="${1:-8000}"
    local directory="${2:-.}"

    if ! has python3; then
        printf 'python3 is required.\n' >&2
        return 1
    fi

    printf 'Serving %s at http://127.0.0.1:%s\n' "$directory" "$port"
    python3 -m http.server "$port" \
        --bind 127.0.0.1 \
        --directory "$directory"
}
```

This server is intended for local development and file sharing, not production hosting.

To expose it deliberately on the local network:

```bash
serve-lan() {
    local port="${1:-8000}"
    local directory="${2:-.}"

    python3 -m http.server "$port" \
        --bind 0.0.0.0 \
        --directory "$directory"
}
```

---

# System Monitoring

```bash
alias mem='free -h'
alias processes='ps aux'
alias psmem='ps aux --sort=-%mem'
alias psmem10='ps aux --sort=-%mem | head -11'
alias pscpu='ps aux --sort=-%cpu'
alias pscpu10='ps aux --sort=-%cpu | head -11'
alias uptimeh='uptime'
alias load='uptime'
alias kernel='uname -a'
```

macOS alternatives:

```bash
if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
    alias mem='vm_stat'
    alias psmem='ps aux | sort -nrk 4'
    alias psmem10='ps aux | sort -nrk 4 | head -10'
    alias pscpu='ps aux | sort -nrk 3'
    alias pscpu10='ps aux | sort -nrk 3 | head -10'
fi
```

Process search:

```bash
psgrep() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: psgrep <pattern>\n' >&2
        return 2
    fi

    ps aux | grep -i -- "$*" | grep -v grep
}
```

---

# Linux System Information

```bash
if [ "$AWESOME_ALIAS_OS" = "linux" ]; then
    alias cpuinfo='lscpu'
    alias blockdevices='lsblk -f'
    alias pci='lspci'
    alias usb='lsusb'
    alias mounts='findmnt'
    alias journalerrors='journalctl -p err..alert -b'
    alias failedservices='systemctl --failed'
    alias services='systemctl --type=service'
fi
```

GPU inspection:

```bash
if has nvidia-smi; then
    alias gpu='nvidia-smi'
    alias gpuwatch='watch -n 2 nvidia-smi'
fi
```

The old Xorg log-based GPU-memory alias is unreliable on modern Wayland, headless, containerized, and non-Xorg systems.

---

# systemd and Logs

```bash
if has systemctl; then
    alias sc='systemctl'
    alias scu='systemctl --user'
    alias jc='journalctl'
    alias jcf='journalctl --follow'
    alias jcb='journalctl --boot'
    alias jcxe='journalctl -xe'
fi
```

Functions:

```bash
svcstatus() {
    systemctl status "$@"
}

svclogs() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: svclogs <service> [journalctl-options]\n' >&2
        return 2
    fi

    local service="$1"
    shift
    journalctl -u "$service" "$@"
}
```

---

# Package Management

Do not use one generic `update` alias for every operating system. Package-management commands differ materially between distributions.

## Debian and Ubuntu

```bash
if has apt; then
    alias aptup='sudo apt update'
    alias aptupgrade='sudo apt update && sudo apt upgrade'
    alias aptfull='sudo apt update && sudo apt full-upgrade'
    alias apti='sudo apt install'
    alias aptr='sudo apt remove'
    alias aptpurge='sudo apt purge'
    alias aptsearch='apt search'
    alias aptclean='sudo apt autoremove'
fi
```

## Fedora, RHEL and Compatible Systems

```bash
if has dnf; then
    alias dnfup='sudo dnf upgrade --refresh'
    alias dnfi='sudo dnf install'
    alias dnfr='sudo dnf remove'
    alias dnfsearch='dnf search'
fi
```

## Arch Linux

```bash
if has pacman; then
    alias pacup='sudo pacman -Syu'
    alias paci='sudo pacman -S'
    alias pacr='sudo pacman -Rns'
    alias pacsearch='pacman -Ss'
fi
```

## Alpine Linux

```bash
if has apk; then
    alias apkup='sudo apk update && sudo apk upgrade'
    alias apki='sudo apk add'
    alias apkr='sudo apk del'
fi
```

## Homebrew

```bash
if has brew; then
    alias brewup='brew update && brew upgrade'
    alias brewi='brew install'
    alias brewr='brew uninstall'
    alias brewsearch='brew search'
    alias brewdoctor='brew doctor'
    alias brewcleanup='brew cleanup'
    alias brewservices='brew services list'
fi
```

Automatic `-y` should not be added universally. Users should see and approve substantial package upgrades unless operating within controlled automation.

---

# macOS

```bash
if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
    alias finder='open .'
    alias showfiles='defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder'
    alias hidefiles='defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder'
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    alias sleepnow='pmset sleepnow'
    alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
    alias cleanupds='find . -name ".DS_Store" -type f -delete'
    alias copy='pbcopy'
    alias paste='pbpaste'
fi
```

Application launch function:

```bash
app() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: app <application-name> [files]\n' >&2
        return 2
    fi

    open -a "$@"
}
```

---

# Service and Power Operations

Commands that restart or shut down a machine should remain explicit.

```bash
alias sys-reboot='sudo systemctl reboot'
alias sys-poweroff='sudo systemctl poweroff'
alias sys-suspend='sudo systemctl suspend'
```

Do not redefine standard commands such as `reboot`, `shutdown`, `halt`, or `poweroff`. Replacing them can hide platform-specific behaviour and surprise administrators.

---

# Node.js and JavaScript

```bash
if has npm; then
    alias ni='npm install'
    alias nid='npm install --save-dev'
    alias nr='npm run'
    alias nrd='npm run dev'
    alias nrb='npm run build'
    alias nrt='npm test'
    alias noutdated='npm outdated'
fi

if has pnpm; then
    alias p='pnpm'
    alias pi='pnpm install'
    alias pa='pnpm add'
    alias pad='pnpm add --save-dev'
    alias pr='pnpm run'
    alias pd='pnpm dev'
    alias pb='pnpm build'
    alias pt='pnpm test'
fi

if has bun; then
    alias bunr='bun run'
    alias buni='bun install'
    alias buna='bun add'
    alias bund='bun run dev'
fi
```

Avoid `pt='ping facebook.com'`, because `pt` is more useful for package-manager testing conventions and Facebook is not an appropriate operational connectivity dependency.

---

# Python

```bash
if has python3; then
    alias py='python3'
    alias pyserver='python3 -m http.server'
fi

if has pip3; then
    alias pip='pip3'
fi
```

Virtual environment function:

```bash
venv() {
    local directory="${1:-.venv}"

    python3 -m venv "$directory" || return
    # shellcheck disable=SC1090
    source "$directory/bin/activate"
}
```

Using `python -m pip` is generally safer than relying on a potentially ambiguous `pip` executable:

```bash
alias pypip='python3 -m pip'
alias pyinstall='python3 -m pip install'
alias pyupgrade='python3 -m pip install --upgrade'
```

---

# Java and Build Tools

```bash
if has mvn; then
    alias mvc='mvn clean'
    alias mvi='mvn install'
    alias mvt='mvn test'
    alias mvp='mvn package'
fi

if has gradle; then
    alias gr='gradle'
    alias grb='gradle build'
    alias grt='gradle test'
fi
```

Alias conflicts must be resolved by module. For example:

* `mvi` may mean interactive `mv` or Maven install.
* `grb` may mean Git rebase or Gradle build.

Prefer explicit alternatives:

```bash
alias mvni='mvn install'
alias gradleb='gradle build'
```

---

# Go

```bash
if has go; then
    alias gor='go run'
    alias gob='go build'
    alias got='go test ./...'
    alias gofmtall='gofmt -w .'
    alias gomodtidy='go mod tidy'
    alias govetall='go vet ./...'
fi
```

---

# Rust

```bash
if has cargo; then
    alias cr='cargo run'
    alias cb='cargo build'
    alias cbr='cargo build --release'
    alias ct='cargo test'
    alias cc='cargo check'
    alias cf='cargo fmt'
    alias cclippy='cargo clippy'
fi
```

Because aliases such as `c`, `cb`, and `cc` commonly conflict with clear, clipboard, or compilers, a safer prefix is:

```bash
alias cargo-r='cargo run'
alias cargo-b='cargo build'
alias cargo-t='cargo test'
```

---

# Databases

```bash
if has psql; then
    alias pgcli-local='psql -h localhost'
fi

if has redis-cli; then
    alias redis-local='redis-cli -h 127.0.0.1'
fi

if has mongosh; then
    alias mongo-local='mongosh mongodb://127.0.0.1:27017'
fi
```

Do not embed usernames, passwords, tokens, production hosts, or connection strings in a public alias collection.

---

# JSON and YAML

```bash
if has jq; then
    alias json='jq .'
    alias jsonc='jq --compact-output'
fi

if has yq; then
    alias yaml='yq'
fi
```

Clipboard JSON formatting:

```bash
jsonclip() {
    if ! has jq; then
        printf 'jq is required.\n' >&2
        return 1
    fi

    if [ "$AWESOME_ALIAS_OS" = "macos" ]; then
        pbpaste | jq . | pbcopy
    elif has xclip; then
        xclip -selection clipboard -o |
            jq . |
            xclip -selection clipboard
    else
        printf 'Clipboard integration requires pbcopy/pbpaste or xclip.\n' >&2
        return 1
    fi
}
```

---

# TLS and Certificates

```bash
if has openssl; then
    alias opensslver='openssl version -a'
fi
```

Certificate inspection:

```bash
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
```

---

# Cloud CLIs

## AWS

```bash
if has aws; then
    alias awswho='aws sts get-caller-identity'
    alias awsprofiles='aws configure list-profiles'
    alias awsregions='aws ec2 describe-regions --output table'
fi
```

## Azure

```bash
if has az; then
    alias azwho='az account show'
    alias azaccounts='az account list --output table'
    alias azgroups='az group list --output table'
fi
```

## Google Cloud

```bash
if has gcloud; then
    alias gcwho='gcloud auth list'
    alias gcproject='gcloud config get-value project'
    alias gcprojects='gcloud projects list'
fi
```

Do not add short aliases for deleting cloud resources, changing production accounts, or applying infrastructure globally.

---

# Modern CLI Enhancements

These aliases activate only when the corresponding optional tool is installed.

## eza

```bash
if has eza; then
    alias l='eza --long --all --group-directories-first --git'
    alias ll='eza --long --group-directories-first --git'
    alias la='eza --all --group-directories-first'
    alias tree2='eza --tree --level=2'
    alias tree3='eza --tree --level=3'
fi
```

## bat

```bash
if has bat; then
    alias cat='bat --paging=never'
    alias catp='bat --plain --paging=never'
fi
```

Some distributions install it as `batcat`:

```bash
if ! has bat && has batcat; then
    alias bat='batcat'
fi
```

Overriding `cat` is optional because scripts and copied instructions may depend on traditional `cat` behaviour.

## ripgrep

```bash
if has rg; then
    alias rgf='rg --files'
    alias rgi='rg --ignore-case'
    alias rgh='rg --hidden --glob "!.git/*"'
fi
```

## fd

```bash
if has fd; then
    alias findf='fd --type file'
    alias findd='fd --type directory'
elif has fdfind; then
    alias fd='fdfind'
fi
```

## Other Optional Tools

```bash
has btop && alias top='btop'
has htop && ! has btop && alias top='htop'
has lazygit && alias lg='lazygit'
has lazydocker && alias ldocker='lazydocker'
has dust && alias dustusage='dust'
has procs && alias psmodern='procs'
has delta && alias gitdiff='git diff'
has zoxide && eval "$(zoxide init "${SHELL##*/}")"
```

Users should understand tool behaviour before replacing foundational commands such as `cat`, `top`, `find`, or `ps`.

---

# Shell Completion

Aliases are most useful when tab completion continues to work.

## Bash

```bash
if has kubectl; then
    source <(kubectl completion bash)
    complete -o default -F __start_kubectl k
fi

if has helm; then
    source <(helm completion bash)
fi

if has docker; then
    # Docker completion is frequently installed by the package manager.
    # Load it from the system completion directory where available.
    :
fi
```

## Zsh

```zsh
autoload -Uz compinit
compinit

if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
    compdef k=kubectl
fi

if command -v helm >/dev/null 2>&1; then
    source <(helm completion zsh)
fi
```

---

# Optional Administrative Commands

Potentially disruptive commands should live in a separate file that is not loaded by default.

Example:

```bash
# Source manually only when required:
# source "$HOME/.awesome-bash-alias/optional/dangerous.sh"
```

`optional/dangerous.sh`:

```bash
confirm() {
    local prompt="${1:-Continue?}"
    local expected="${2:-YES}"
    local answer

    printf '%s Type %s to continue: ' "$prompt" "$expected"
    read -r answer
    [ "$answer" = "$expected" ]
}

docker-remove-stopped() {
    docker ps --all --filter status=exited

    confirm \
        "Remove every stopped Docker container?" \
        "REMOVE-STOPPED" ||
        return 1

    local containers
    containers="$(docker ps --quiet --all --filter status=exited)"

    [ -z "$containers" ] && {
        printf 'No stopped containers.\n'
        return 0
    }

    # shellcheck disable=SC2086
    docker rm $containers
}

docker-prune-all() {
    docker system df

    confirm \
        "Remove all unused Docker data, including unused images?" \
        "PRUNE-DOCKER" ||
        return 1

    docker system prune --all
}
```

Destructive commands should:

1. Display the affected resources.
2. Require a specific confirmation phrase.
3. Avoid implicit privilege escalation.
4. Avoid running automatically during shell startup.
5. Be documented separately.

---

# Commands Intentionally Excluded

The following patterns are deliberately excluded from the default collection:

```bash
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker system prune -af
git reset --hard && git clean -df
rm -rf *
kubectl delete all --all
terraform destroy -auto-approve
```

They may be valid in controlled automation, but they are too destructive for short, easily mistyped interactive aliases.

Also excluded:

* Generic `update` alias with inconsistent platform behaviour
* Automatic `sudo` on every Docker command
* Python 2 `SimpleHTTPServer`
* `netstat` as the only method of checking ports
* Xorg-log-based GPU detection
* Duplicate alias names
* Embedded cloud credentials
* Production hostnames
* Commands targeting third-party websites for basic connectivity testing
* Global modification of commands without an opt-in mechanism

---

# Alias Naming Convention

Recommended prefixes:

| Area           | Prefix | Examples                |
| -------------- | -----: | ----------------------- |
| Git            |    `g` | `gs`, `gaa`, `glog`     |
| Docker         |    `d` | `dps`, `dsh`, `dlogf`   |
| Docker Compose |   `dc` | `dcu`, `dcd`, `dclf`    |
| Kubernetes     |    `k` | `kgp`, `kctx`, `kpf`    |
| Helm           |   `hm` | `hmls`, `hmrepo`        |
| Terraform      |   `tf` | `tfi`, `tfp`, `tfa`     |
| Ansible        |    `a` | `ap`, `ai`, `apcheck`   |
| AWS            |  `aws` | `awswho`, `awsprofiles` |
| Azure          |   `az` | `azwho`, `azaccounts`   |
| Google Cloud   |   `gc` | `gcwho`, `gcproject`    |

Rules:

* Prefer memorable names over the shortest possible names.
* Avoid one-character aliases except for extremely common tools.
* Avoid replacing standard commands by default.
* Avoid aliases whose meanings differ across modules.
* Use verbs for functions that perform actions.
* Use nouns for informational commands.
* Add `-preview`, `-safe`, or `-all` where the scope matters.

---

# Conflict Detection

Provide a helper to identify aliases already configured in the user’s shell:

```bash
alias-exists() {
    alias "$1" >/dev/null 2>&1
}

alias-check() {
    local name

    for name in "$@"; do
        if alias "$name" >/dev/null 2>&1; then
            alias "$name"
        else
            printf '%s: available\n' "$name"
        fi
    done
}
```

Example:

```bash
alias-check h c l ll gs k d dc tf
```

---

# Testing

Use ShellCheck and Bats.

```bash
shellcheck aliases.sh modules/*.sh optional/*.sh
bats tests/
```

Basic test cases should verify:

* All files parse successfully.
* No duplicate alias names exist.
* Optional commands are conditionally loaded.
* Destructive functions require confirmation.
* Linux and macOS branches load correctly.
* Functions properly quote filenames containing spaces.
* Commands do not unexpectedly invoke `sudo`.
* No aliases contain credentials or environment-specific secrets.

Syntax check:

```bash
bash -n aliases.sh
bash -n modules/*.sh
```

---

# Security Guidance

Aliases are executable shell configuration. Treat third-party alias collections like source code.

Before installation:

1. Review every sourced file.
2. Search for `sudo`, `eval`, `curl`, `wget`, `rm`, `chmod`, and `chown`.
3. Verify remote URLs.
4. Avoid piping remote scripts directly into a privileged shell.
5. Do not store secrets in aliases.
6. Do not load files writable by untrusted users.
7. Quote paths and positional parameters.
8. Avoid `eval` unless the input is generated by a trusted local executable.
9. Use explicit cloud profiles and Kubernetes contexts.
10. Preview destructive operations before execution.

---

# Contribution Guidelines

Contributions are welcome.

A proposed alias or function should:

* Solve a recurring terminal task.
* Have an understandable name.
* Avoid duplication.
* Work across supported environments or be clearly OS-specific.
* Include appropriate quoting.
* Avoid embedded usernames, paths, credentials, or hostnames.
* Include command-existence checks for optional tools.
* Include confirmation for destructive behaviour.
* Include documentation and an example.
* Pass ShellCheck and repository tests.

Pull requests adding many aliases should group them by domain rather than placing everything in one file.

---

# Recommended Default Modules

For most developers:

```bash
source modules/core.sh
source modules/navigation.sh
source modules/files.sh
source modules/git.sh
source modules/development.sh
source modules/networking.sh
```

For DevOps and platform engineers:

```bash
source modules/docker.sh
source modules/kubernetes.sh
source modules/infrastructure.sh
source modules/cloud.sh
source modules/system.sh
```

Optional modern tools:

```bash
source optional/modern-cli.sh
```

Destructive administrative helpers should not be loaded automatically:

```bash
# Load manually during controlled maintenance only.
# source optional/dangerous.sh
```

---

# Suggested Starter Profile

Users who prefer one compact file can begin with:

```bash
# Helpers
has() {
    command -v "$1" >/dev/null 2>&1
}

# Core
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias dfh='df -h'

# Git
alias g='git'
alias gs='git status --short --branch'
alias gaa='git add --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gcm='git commit -m'
alias glog='git log --oneline --decorate --graph'
alias gfa='git fetch --all --prune'
alias glr='git pull --rebase'
alias gpu='git push --set-upstream origin HEAD'
alias gsw='git switch'
alias gswc='git switch --create'
alias grs='git restore'

# Docker
if has docker; then
    alias d='docker'
    alias dps='docker ps'
    alias dpsa='docker ps --all'
    alias di='docker images'
    alias dlogf='docker logs --follow --tail 200'
    alias dstats='docker stats'

    if docker compose version >/dev/null 2>&1; then
        alias dc='docker compose'
        alias dcu='docker compose up'
        alias dcud='docker compose up --detach'
        alias dcd='docker compose down'
        alias dcps='docker compose ps'
        alias dclf='docker compose logs --follow --tail 200'
    fi
fi

# Kubernetes
if has kubectl; then
    alias k='kubectl'
    alias kgp='kubectl get pods'
    alias kgpa='kubectl get pods --all-namespaces'
    alias kgs='kubectl get services'
    alias kgn='kubectl get nodes'
    alias klf='kubectl logs --follow --tail=200'
    alias kctx='kubectl config current-context'
    alias kctxs='kubectl config get-contexts'
    alias kev='kubectl get events --sort-by=.metadata.creationTimestamp'
fi

# Optional modern tools
has jq && alias json='jq .'
has lazygit && alias lg='lazygit'
has btop && alias top='btop'
```

This starter profile is intentionally conservative. Users can add domain-specific modules as their workflow grows.

---

# Roadmap

Planned improvements:

* Automated duplicate-alias detection
* Bash and Zsh compatibility tests
* Interactive installer
* Profile selection: Developer, DevOps, Kubernetes, Cloud, macOS
* Alias search command
* Generated documentation from module metadata
* Shell completion tests
* Containerized test matrix
* GitHub Actions validation
* Homebrew formula
* Debian package
* Secure remote installation with checksums
* Fish and PowerShell companion projects
* Community alias usage analytics
* Versioned release notes
* Deprecation policy

---

# Philosophy

The best alias is not necessarily the shortest.

A good alias should be:

* Predictable
* Memorable
* Safe
* Discoverable
* Portable
* Easy to remove
* Clear about its operational impact

Terminal productivity should reduce cognitive load—not increase operational risk.
