#!/usr/bin/env bash
# Uninstall script for procs on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting procs uninstallation on macOS..."
    if brew list procs &> /dev/null 2>&1; then brew uninstall procs; fi
    log_success "procs uninstalled"
    exit 0
}

main "$@"
