#!/usr/bin/env bash
# Uninstall script for lsd on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting lsd uninstallation on Linux..."
    if command -v apt-get &> /dev/null; then sudo apt-get remove -y lsd 2>&1 || true; fi
    if command -v dnf &> /dev/null; then sudo dnf remove -y lsd 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm lsd 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall lsd 2>&1 || true; fi
    log_success "lsd uninstalled"
    exit 0
}

main "$@"
