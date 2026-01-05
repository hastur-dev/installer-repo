#!/usr/bin/env bash
# Install script for navi on Linux (interactive cheatsheet)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting navi installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install navi && installed=true
    fi

    # Try cargo
    if [[ "$installed" == "false" ]] && command -v cargo &> /dev/null; then
        cargo install navi && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/denisidoro/navi/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="x86_64" ;;
                aarch64) arch="aarch64" ;;
            esac
            curl -sL "https://github.com/denisidoro/navi/releases/download/v${version}/navi-v${version}-${arch}-unknown-linux-musl.tar.gz" | tar xz -C /usr/local/bin
            chmod +x /usr/local/bin/navi
            installed=true
        fi
    fi

    if command -v navi &> /dev/null; then
        log_success "navi installed: $(navi --version 2>&1)"
    else
        log_error "Failed to install navi"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
