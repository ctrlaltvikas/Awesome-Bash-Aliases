#!/usr/bin/env bash
# ==============================================================================
# 🚀 Awesome Bash Aliases — Master Loader
# ==============================================================================
# Universal loader that dynamically detects your operating system and loads all
# modular alias files in strictly sorted numeric order.
#
# Supported Shells: Bash 3.2+, Bash 4+, Bash 5+, Zsh
# Website: https://vikaskyadav.github.io/awesome-bash-alias/
# ==============================================================================

# Ensure alias expansion is enabled in Bash non-interactive subshells
shopt -s expand_aliases 2>/dev/null || true

# Determine directory containing this loader script
_ABA_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"

# Operating-system detection
if [ -z "${AWESOME_ALIAS_OS:-}" ]; then
    case "$(uname -s)" in
        Darwin) export AWESOME_ALIAS_OS="macos" ;;
        Linux)  export AWESOME_ALIAS_OS="linux" ;;
        *)      export AWESOME_ALIAS_OS="other" ;;
    esac
fi

# Load core aliases directory in numerical order
if [ -d "${_ABA_ROOT}/aliases" ]; then
    for _aba_file in "${_ABA_ROOT}/aliases/"*.aliases.bash; do
        if [ -r "$_aba_file" ]; then
            # Check if this module is in skip list (comma-separated, e.g. AWESOME_ALIAS_SKIP="k8s,docker")
            _aba_basename="$(basename "$_aba_file")"
            _aba_tag="${_aba_basename#[0-9]*-}"
            _aba_tag="${_aba_tag%.aliases.bash}"

            case ",${AWESOME_ALIAS_SKIP:-}," in
                *,"${_aba_tag}",*|*,"${_aba_basename}",*)
                    continue
                    ;;
            esac

            # shellcheck disable=SC1090
            source "$_aba_file"
        fi
    done
    unset _aba_file _aba_basename _aba_tag
fi

unset _ABA_ROOT
