#!/usr/bin/env bash
# Install script for yq on Linux (YAML processor)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting yq installation on Linux..."

    if command -v snap &> /dev/null; then
        sudo snap install yq
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update -y
        # Download binary directly as apt package may be outdated
        local version
        version=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
        sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_amd64"
        sudo chmod +x /usr/local/bin/yq
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y yq 2>/dev/null || {
            local version
            version=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | grep tag_name | cut -d '"' -f 4)
            sudo wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_amd64"
            sudo chmod +x /usr/local/bin/yq
        }
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm yq
    fi

    if command -v yq &> /dev/null; then
        log_success "yq installed: $(yq --version 2>&1)"
    else
        log_error "Failed to install yq"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
