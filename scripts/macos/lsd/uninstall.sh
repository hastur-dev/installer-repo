#!/usr/bin/env bash
# Uninstall script for lsd on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting lsd uninstallation on macOS..."
    if brew list lsd &> /dev/null 2>&1; then brew uninstall lsd; fi
    log_success "lsd uninstalled"
    exit 0
}

main "$@"
