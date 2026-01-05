#!/usr/bin/env bash
# Install script for bandwhich on Linux (bandwidth monitor)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting bandwhich installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install bandwhich
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm bandwhich
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/imsnif/bandwhich/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/bandwhich.tar.gz "https://github.com/imsnif/bandwhich/releases/download/${version}/bandwhich-${version}-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/bandwhich.tar.gz -C /tmp
        sudo mv /tmp/bandwhich /usr/local/bin/
        rm -f /tmp/bandwhich.tar.gz
    fi

    if command -v bandwhich &> /dev/null; then
        log_success "bandwhich installed: $(bandwhich --version 2>&1)"
        log_info "Run with sudo for full functionality"
    else
        log_error "Failed to install bandwhich"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
