#!/usr/bin/env bash
# Install script for restic on Linux (backup program)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting restic installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y && sudo apt-get install -y restic
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y restic
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm restic
    else
        # Download from GitHub releases
        local version
        version=$(curl -s https://api.github.com/repos/restic/restic/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -qO /tmp/restic.bz2 "https://github.com/restic/restic/releases/download/${version}/restic_${version#v}_linux_amd64.bz2"
        bunzip2 /tmp/restic.bz2
        sudo mv /tmp/restic /usr/local/bin/
        sudo chmod +x /usr/local/bin/restic
    fi

    if command -v restic &> /dev/null; then
        log_success "restic installed: $(restic version 2>&1)"
    else
        log_error "Failed to install restic"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
