#!/usr/bin/env bash
# Uninstall script for hexyl on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hexyl uninstallation on Linux..."
    if command -v apt-get &> /dev/null; then sudo apt-get remove -y hexyl 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm hexyl 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall hexyl 2>&1 || true; fi
    log_success "hexyl uninstalled"
    exit 0
}

main "$@"
