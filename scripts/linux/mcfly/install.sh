#!/usr/bin/env bash
# Install script for mcfly on Linux (intelligent shell history)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mcfly installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install mcfly
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm mcfly
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/cantino/mcfly/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/mcfly.tar.gz "https://github.com/cantino/mcfly/releases/download/${version}/mcfly-${version}-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/mcfly.tar.gz -C /tmp
        sudo mv /tmp/mcfly /usr/local/bin/
        rm -f /tmp/mcfly.tar.gz
    fi

    if command -v mcfly &> /dev/null; then
        log_success "mcfly installed: $(mcfly --version 2>&1)"
        log_info "Add 'eval \"\$(mcfly init bash)\"' to your .bashrc"
        log_info "Or 'eval \"\$(mcfly init zsh)\"' to your .zshrc"
    else
        log_error "Failed to install mcfly"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
