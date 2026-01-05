#!/usr/bin/env bash
# Install script for difftastic on Linux (structural diff)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting difftastic installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install difftastic
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm difftastic
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/Wilfred/difftastic/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/difft.tar.gz "https://github.com/Wilfred/difftastic/releases/download/${version}/difft-x86_64-unknown-linux-gnu.tar.gz"
        tar -xzf /tmp/difft.tar.gz -C /tmp
        sudo mv /tmp/difft /usr/local/bin/
        rm -f /tmp/difft.tar.gz
    fi

    if command -v difft &> /dev/null; then
        log_success "difftastic installed: $(difft --version 2>&1)"
        log_info "Set as git diff: git config --global diff.external difft"
    else
        log_error "Failed to install difftastic"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
