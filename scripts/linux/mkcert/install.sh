#!/usr/bin/env bash
# Install script for mkcert on Linux (local dev certificates)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mkcert installation on Linux..."

    # Install dependencies for CA
    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y libnss3-tools mkcert 2>/dev/null || {
            sudo apt-get install -y libnss3-tools
            # Download binary
            local version
            version=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep tag_name | cut -d '"' -f 4)
            sudo wget -qO /usr/local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/${version}/mkcert-${version}-linux-amd64"
            sudo chmod +x /usr/local/bin/mkcert
        }
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y nss-tools mkcert 2>/dev/null || {
            sudo dnf install -y nss-tools
            local version
            version=$(curl -s https://api.github.com/repos/FiloSottile/mkcert/releases/latest | grep tag_name | cut -d '"' -f 4)
            sudo wget -qO /usr/local/bin/mkcert "https://github.com/FiloSottile/mkcert/releases/download/${version}/mkcert-${version}-linux-amd64"
            sudo chmod +x /usr/local/bin/mkcert
        }
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm mkcert
    fi

    if command -v mkcert &> /dev/null; then
        log_success "mkcert installed: $(mkcert --version 2>&1)"
        log_info "Run 'mkcert -install' to install the local CA"
    else
        log_error "Failed to install mkcert"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
