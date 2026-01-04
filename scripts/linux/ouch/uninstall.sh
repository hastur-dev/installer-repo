#!/usr/bin/env bash
# Uninstall script for ouch on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ouch uninstallation on Linux..."
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm ouch 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall ouch 2>&1 || true; fi
    log_success "ouch uninstalled"
    exit 0
}

main "$@"
