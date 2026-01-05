#!/usr/bin/env bash
# Install script for dive on Linux (Docker image analyzer)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dive installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install dive && installed=true
    fi

    # Try snap
    if [[ "$installed" == "false" ]] && command -v snap &> /dev/null; then
        snap install dive && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_linux_${arch}.tar.gz" | tar xz -C /usr/local/bin dive
            chmod +x /usr/local/bin/dive
            installed=true
        fi
    fi

    if command -v dive &> /dev/null; then
        log_success "dive installed: $(dive version 2>&1 | head -1)"
    else
        log_error "Failed to install dive"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
