#!/usr/bin/env bash
# Uninstall script for watchexec on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting watchexec uninstallation on macOS..."
    if brew list watchexec &> /dev/null 2>&1; then brew uninstall watchexec; fi
    log_success "watchexec uninstalled"
    exit 0
}

main "$@"
