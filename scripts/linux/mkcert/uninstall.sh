#!/usr/bin/env bash
# Uninstall script for mkcert on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mkcert uninstallation on Linux..."

    # Uninstall local CA first
    if command -v mkcert &> /dev/null; then
        mkcert -uninstall 2>/dev/null || true
    fi

    if command -v apt-get &> /dev/null; then
        sudo apt-get remove -y mkcert 2>/dev/null || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf remove -y mkcert 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm mkcert 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/mkcert 2>/dev/null || true

    log_success "mkcert uninstalled"
    exit 0
}

main "$@"
