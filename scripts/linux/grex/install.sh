#!/usr/bin/env bash
# Install script for grex on Linux (regex generator)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting grex installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install grex
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm grex
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/pemistahl/grex/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/grex.tar.gz "https://github.com/pemistahl/grex/releases/download/${version}/grex-${version}-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/grex.tar.gz -C /tmp
        sudo mv /tmp/grex /usr/local/bin/
        rm -f /tmp/grex.tar.gz
    fi

    if command -v grex &> /dev/null; then
        log_success "grex installed: $(grex --version 2>&1)"
    else
        log_error "Failed to install grex"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
