#!/usr/bin/env bash
# Install script for helix on Linux (post-modern text editor)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting helix installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo add-apt-repository -y ppa:maveonair/helix-editor 2>/dev/null || true
        sudo apt-get update -y
        sudo apt-get install -y helix 2>/dev/null || {
            # Fallback to AppImage
            local version
            version=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep tag_name | cut -d '"' -f 4)
            wget -qO /tmp/helix.tar.xz "https://github.com/helix-editor/helix/releases/download/${version}/helix-${version}-x86_64-linux.tar.xz"
            tar -xf /tmp/helix.tar.xz -C /tmp
            sudo mv /tmp/helix-*/hx /usr/local/bin/
            sudo mkdir -p /usr/share/helix
            sudo mv /tmp/helix-*/runtime /usr/share/helix/
            rm -rf /tmp/helix.tar.xz /tmp/helix-*
        }
    elif command -v dnf &> /dev/null; then
        sudo dnf copr enable -y varlad/helix 2>/dev/null || true
        sudo dnf install -y helix 2>/dev/null || true
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm helix
    fi

    if command -v hx &> /dev/null; then
        log_success "helix installed: $(hx --version 2>&1)"
    else
        log_error "Failed to install helix"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
