#!/usr/bin/env bash
# Uninstall script for zellij on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting zellij uninstallation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo uninstall zellij 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm zellij 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/zellij 2>/dev/null || true

    log_success "zellij uninstalled"
    exit 0
}

main "$@"
