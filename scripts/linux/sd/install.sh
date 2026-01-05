#!/usr/bin/env bash
# Install script for sd on Linux (find & replace CLI)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting sd installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install sd
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm sd
    elif command -v apt-get &> /dev/null; then
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/chmln/sd/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/sd.tar.gz "https://github.com/chmln/sd/releases/download/${version}/sd-${version}-x86_64-unknown-linux-gnu.tar.gz"
        tar -xzf /tmp/sd.tar.gz -C /tmp
        sudo mv /tmp/sd-*/sd /usr/local/bin/
        rm -rf /tmp/sd.tar.gz /tmp/sd-*
    fi

    if command -v sd &> /dev/null; then
        log_success "sd installed: $(sd --version 2>&1)"
    else
        log_error "Failed to install sd"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
