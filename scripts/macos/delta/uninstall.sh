#!/usr/bin/env bash
# Uninstall script for delta on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting delta uninstallation on macOS..."
    if brew list git-delta &> /dev/null 2>&1; then brew uninstall git-delta; fi
    log_success "delta uninstalled"
    exit 0
}

main "$@"
