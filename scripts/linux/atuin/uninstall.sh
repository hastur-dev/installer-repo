#!/usr/bin/env bash
# Uninstall script for atuin on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting atuin uninstallation on Linux..."
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm atuin 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall atuin 2>&1 || true; fi
    log_success "atuin uninstalled"
    log_info "Remember to remove atuin init from your shell config"
    exit 0
}

main "$@"
