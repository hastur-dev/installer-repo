#!/usr/bin/env bash
# Install script for zellij on Linux (terminal multiplexer)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting zellij installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install zellij
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm zellij
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/zellij.tar.gz "https://github.com/zellij-org/zellij/releases/download/${version}/zellij-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/zellij.tar.gz -C /tmp
        sudo mv /tmp/zellij /usr/local/bin/
        rm -f /tmp/zellij.tar.gz
    fi

    if command -v zellij &> /dev/null; then
        log_success "zellij installed: $(zellij --version 2>&1)"
    else
        log_error "Failed to install zellij"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
