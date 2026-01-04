#!/usr/bin/env bash
# Uninstall script for bottom on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting bottom uninstallation on Linux..."
    if command -v apt-get &> /dev/null; then sudo apt-get remove -y bottom 2>&1 || true; fi
    if command -v dnf &> /dev/null; then sudo dnf remove -y bottom 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm bottom 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall bottom 2>&1 || true; fi
    log_success "bottom uninstalled"
    exit 0
}

main "$@"
