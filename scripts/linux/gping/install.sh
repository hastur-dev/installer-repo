#!/usr/bin/env bash
# Install script for gping on Linux (ping with graph)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gping installation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo install gping
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm gping
    elif command -v apt-get &> /dev/null; then
        # Add repository
        echo "deb http://packages.azlux.fr/debian/ stable main" | sudo tee /etc/apt/sources.list.d/azlux.list
        wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
        sudo apt-get update -y
        sudo apt-get install -y gping
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/orf/gping/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/gping.tar.gz "https://github.com/orf/gping/releases/download/${version}/gping-x86_64-unknown-linux-musl.tar.gz"
        tar -xzf /tmp/gping.tar.gz -C /tmp
        sudo mv /tmp/gping /usr/local/bin/
        rm -f /tmp/gping.tar.gz
    fi

    if command -v gping &> /dev/null; then
        log_success "gping installed: $(gping --version 2>&1)"
    else
        log_error "Failed to install gping"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
