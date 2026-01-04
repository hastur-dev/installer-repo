#!/usr/bin/env bash
# Uninstall script for glow on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting glow uninstallation on Linux..."
    if command -v apt-get &> /dev/null; then sudo apt-get remove -y glow 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm glow 2>&1 || true; fi
    log_success "glow uninstalled"
    exit 0
}

main "$@"
