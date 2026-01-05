#!/usr/bin/env bash
# Install script for sops on Linux (secrets management)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting sops installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install sops && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/getsops/sops/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/getsops/sops/releases/download/v${version}/sops-v${version}.linux.${arch}" -o /usr/local/bin/sops
            chmod +x /usr/local/bin/sops
            installed=true
        fi
    fi

    if command -v sops &> /dev/null; then
        log_success "sops installed: $(sops --version 2>&1)"
    else
        log_error "Failed to install sops"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
