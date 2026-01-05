#!/usr/bin/env bash
# Install script for dog on Linux (DNS client)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dog installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install dog
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm dog
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/ogham/dog/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/dog.zip "https://github.com/ogham/dog/releases/download/${version}/dog-${version}-x86_64-unknown-linux-gnu.zip"
        unzip -o /tmp/dog.zip -d /tmp
        sudo mv /tmp/bin/dog /usr/local/bin/
        rm -rf /tmp/dog.zip /tmp/bin
    fi

    if command -v dog &> /dev/null; then
        log_success "dog installed: $(dog --version 2>&1)"
    else
        log_error "Failed to install dog"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
