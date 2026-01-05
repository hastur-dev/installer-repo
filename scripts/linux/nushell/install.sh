#!/usr/bin/env bash
# Install script for nushell on Linux (modern shell)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting nushell installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install nu
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm nushell
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/nu.tar.gz "https://github.com/nushell/nushell/releases/download/${version}/nu-${version}-x86_64-unknown-linux-gnu.tar.gz"
        tar -xzf /tmp/nu.tar.gz -C /tmp
        sudo mv /tmp/nu-*/nu /usr/local/bin/
        rm -rf /tmp/nu.tar.gz /tmp/nu-*
    fi

    if command -v nu &> /dev/null; then
        log_success "nushell installed: $(nu --version 2>&1)"
    else
        log_error "Failed to install nushell"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
