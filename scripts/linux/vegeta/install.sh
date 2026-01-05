#!/usr/bin/env bash
# Install script for vegeta on Linux (HTTP load testing)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vegeta installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install vegeta && installed=true
    fi

    # Try go install
    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install github.com/tsenart/vegeta@latest && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/tsenart/vegeta/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/tsenart/vegeta/releases/download/v${version}/vegeta_${version}_linux_${arch}.tar.gz" | tar xz -C /usr/local/bin vegeta
            chmod +x /usr/local/bin/vegeta
            installed=true
        fi
    fi

    if command -v vegeta &> /dev/null; then
        log_success "vegeta installed: $(vegeta --version 2>&1)"
    else
        log_error "Failed to install vegeta"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
