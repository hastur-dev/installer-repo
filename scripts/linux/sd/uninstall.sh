#!/usr/bin/env bash
# Uninstall script for sd on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting sd uninstallation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo uninstall sd 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm sd 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/sd 2>/dev/null || true

    log_success "sd uninstalled"
    exit 0
}

main "$@"
