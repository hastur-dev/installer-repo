#!/usr/bin/env bash
# Uninstall script for fnm on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting fnm uninstallation on Linux..."
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm fnm 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall fnm 2>&1 || true; fi
    rm -rf ~/.fnm 2>&1 || true
    log_success "fnm uninstalled"
    log_info "Remember to remove fnm env from your shell config"
    exit 0
}

main "$@"
