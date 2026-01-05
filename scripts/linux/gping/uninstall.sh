#!/usr/bin/env bash
# Uninstall script for gping on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gping uninstallation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo uninstall gping 2>/dev/null || true
    fi
    if command -v apt-get &> /dev/null; then
        sudo apt-get remove -y gping 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm gping 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/gping 2>/dev/null || true

    log_success "gping uninstalled"
    exit 0
}

main "$@"
