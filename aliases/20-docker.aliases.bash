#!/usr/bin/env bash
# ==============================================================================
# 🐳 20-docker.aliases.bash — Container Lifecycle, Pruning & Debugging Shortcuts
# ==============================================================================
# Production-ready Docker & Compose shortcuts, container lifecycle operations,
# debugging utilities, volume/network inspectors, and guarded pruning routines.
#
# Part of the Awesome Bash Aliases suite.
# Compatible with Bash 3.2+, Bash 4+, Bash 5+, and Zsh.
# ==============================================================================

# ------------------------------------------------------------------------------
# 📦 Core Container & Image Management
# ------------------------------------------------------------------------------

# @name: d
# @category: Docker
# @description: Short alias for the docker CLI command.
# @os: cross-platform
alias d='docker'

# @name: dps
# @category: Docker
# @description: List currently running Docker containers.
# @os: cross-platform
alias dps='docker ps'

# @name: dpsa
# @category: Docker
# @description: List all Docker containers, including stopped and exited ones.
# @os: cross-platform
alias dpsa='docker ps --all'

# @name: di
# @category: Docker
# @description: List locally available Docker images.
# @os: cross-platform
alias di='docker images'

# @name: dimg
# @category: Docker
# @description: List Docker images using modern CLI syntax.
# @os: cross-platform
alias dimg='docker image ls'

# @name: dvol
# @category: Docker
# @description: List all Docker volumes present on the host.
# @os: cross-platform
alias dvol='docker volume ls'

# @name: dnet
# @category: Docker
# @description: List all configured Docker networks.
# @os: cross-platform
alias dnet='docker network ls'

# @name: dinfo
# @category: Docker
# @description: Display system-wide Docker configuration and resource info.
# @os: cross-platform
alias dinfo='docker info'

# @name: dver
# @category: Docker
# @description: Show Docker client and daemon engine versions.
# @os: cross-platform
alias dver='docker version'

# @name: dstats
# @category: Docker
# @description: Stream real-time CPU, memory, and network usage of running containers.
# @os: cross-platform
alias dstats='docker stats'

# @name: dtop
# @category: Docker
# @description: Display running processes of a specified container.
# @os: cross-platform
alias dtop='docker top'

# @name: dinspect
# @category: Docker
# @description: Display detailed low-level JSON configuration of Docker objects.
# @os: cross-platform
alias dinspect='docker inspect'

# ------------------------------------------------------------------------------
# 🔨 Build & Registry Distribution
# ------------------------------------------------------------------------------

# @name: dbuild
# @category: Docker
# @description: Build a container image from a Dockerfile in the current directory.
# @os: cross-platform
alias dbuild='docker build'

# @name: dbuildx
# @category: Docker
# @description: Build multi-architecture container images using Docker Buildx.
# @os: cross-platform
alias dbuildx='docker buildx build'

# @name: dpull
# @category: Docker
# @description: Download container image from configured container registry.
# @os: cross-platform
alias dpull='docker pull'

# @name: dpush
# @category: Docker
# @description: Upload local container image to remote container registry.
# @os: cross-platform
alias dpush='docker push'

# ------------------------------------------------------------------------------
# 📜 Logging & Observability
# ------------------------------------------------------------------------------

# @name: dlog
# @category: Docker
# @description: Fetch stdout and stderr logs of a container.
# @os: cross-platform
alias dlog='docker logs'

# @name: dlogf
# @category: Docker
# @description: Tail and stream the last 200 log lines of a container in real-time.
# @os: cross-platform
alias dlogf='docker logs --follow --tail 200'

# ------------------------------------------------------------------------------
# 🔍 Container Debugging & Interactive Utilities
# ------------------------------------------------------------------------------

# @name: dsh
# @category: Docker
# @description: Open interactive shell in container with auto-detection for bash or sh.
# @os: cross-platform
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

# @name: drun
# @category: Docker
# @description: Run interactive throwaway container with automatic cleanup on exit.
# @os: cross-platform
drun() {
    if [ "$#" -lt 1 ]; then
        printf 'Usage: drun <image> [command]\n' >&2
        return 2
    fi
    docker run --rm -it "$@"
}

# @name: dip
# @category: Docker
# @description: Extract and print IPv4 address assigned to a running container.
# @os: cross-platform
dip() {
    if [ "$#" -ne 1 ]; then
        printf 'Usage: dip <container>\n' >&2
        return 2
    fi

    docker inspect \
        --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
        "$1"
}

# ------------------------------------------------------------------------------
# 🧹 Resource Pruning & Defensive Lifecycle Management
# ------------------------------------------------------------------------------

# @name: dockerclean
# @category: Docker
# @description: Prune all stopped containers, unused networks, and dangling images.
# @os: cross-platform
alias dockerclean='docker system prune -af --volumes'

# @name: dprune-preview
# @category: Docker
# @description: Preview Docker disk space consumption across containers and volumes.
# @os: cross-platform
alias dprune-preview='docker system df'

# @name: dprune
# @category: Docker
# @description: Display disk usage and interactively prompt before pruning system.
# @os: cross-platform
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
            printf 'Operation cancelled.\n'
            ;;
    esac
}

# @name: dstop-all
# @category: Docker
# @description: Interactively prompt and stop all currently running containers.
# @os: cross-platform
dstop-all() {
    local containers
    containers="$(docker ps -q)"

    if [ -z "$containers" ]; then
        printf 'No running containers found.\n'
        return 0
    fi

    printf 'Running container IDs:\n%s\n' "$containers"
    printf 'Stop all running containers? [y/N] '

    local answer
    read -r answer

    case "$answer" in
        y|Y|yes|YES)
            # shellcheck disable=SC2086
            docker stop $containers
            ;;
        *)
            printf 'Operation cancelled.\n'
            ;;
    esac
}

# @name: docker-remove-stopped
# @category: Docker
# @description: Remove exited containers with explicit confirmation safeguard.
# @os: cross-platform
docker-remove-stopped() {
    local containers
    containers="$(docker ps --quiet --all --filter status=exited)"

    if [ -z "$containers" ]; then
        printf 'No stopped containers to remove.\n'
        return 0
    fi

    docker ps --all --filter status=exited
    printf '⚠️ Type REMOVE-STOPPED to permanently delete these containers: '

    local confirmation
    read -r confirmation

    [ "$confirmation" = "REMOVE-STOPPED" ] || {
        printf 'Operation cancelled.\n'
        return 1
    }

    # shellcheck disable=SC2086
    docker rm $containers
}

# @name: docker-prune-all
# @category: Docker
# @description: Prune all unused Docker data with explicit typed PRUNE-DOCKER confirmation.
# @os: cross-platform
docker-prune-all() {
    docker system df
    printf '⚠️ Type PRUNE-DOCKER to remove all unused images, networks, and containers: '

    local confirmation
    read -r confirmation

    [ "$confirmation" = "PRUNE-DOCKER" ] || {
        printf 'Operation cancelled.\n'
        return 1
    }

    docker system prune --all
}

# ------------------------------------------------------------------------------
# 🐋 Docker Compose Ergonomics
# ------------------------------------------------------------------------------

# @name: dc
# @category: Docker
# @description: Shortcut for docker compose subcommands.
# @os: cross-platform
alias dc='docker compose'

# @name: dcu
# @category: Docker
# @description: Create and start containers defined in compose file in foreground.
# @os: cross-platform
alias dcu='docker compose up'

# @name: dcud
# @category: Docker
# @description: Create and start compose containers in background detached mode.
# @os: cross-platform
alias dcud='docker compose up --detach'

# @name: dcub
# @category: Docker
# @description: Build images before starting compose containers in detached mode.
# @os: cross-platform
alias dcub='docker compose up --detach --build'

# @name: dcd
# @category: Docker
# @description: Stop and remove containers, networks, and images created by up.
# @os: cross-platform
alias dcd='docker compose down'

# @name: dcdv
# @category: Docker
# @description: Stop and remove compose containers along with named data volumes.
# @os: cross-platform
alias dcdv='docker compose down --volumes'

# @name: dcps
# @category: Docker
# @description: List running containers managed by active docker compose project.
# @os: cross-platform
alias dcps='docker compose ps'

# @name: dcl
# @category: Docker
# @description: View logs from containers managed by docker compose.
# @os: cross-platform
alias dcl='docker compose logs'

# @name: dclf
# @category: Docker
# @description: Follow and stream the last 200 logs from docker compose services.
# @os: cross-platform
alias dclf='docker compose logs --follow --tail 200'

# @name: dcb
# @category: Docker
# @description: Build or rebuild services defined in compose file.
# @os: cross-platform
alias dcb='docker compose build'

# @name: dcpull
# @category: Docker
# @description: Pull service images defined in compose file from registry.
# @os: cross-platform
alias dcpull='docker compose pull'

# @name: dcconfig
# @category: Docker
# @description: Validate and view resolved compose file configuration.
# @os: cross-platform
alias dcconfig='docker compose config'

# @name: dcrestart
# @category: Docker
# @description: Restart running services in the active compose project.
# @os: cross-platform
alias dcrestart='docker compose restart'
