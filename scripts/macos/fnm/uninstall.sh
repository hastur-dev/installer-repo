#!/usr/bin/env bash
# Uninstall script for fnm on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting fnm uninstallation on macOS..."
    if brew list fnm &> /dev/null 2>&1; then brew uninstall fnm; fi
    rm -rf ~/.fnm 2>&1 || true
    log_success "fnm uninstalled"
    log_info "Remember to remove fnm env from your shell config"
    exit 0
}

main "$@"
