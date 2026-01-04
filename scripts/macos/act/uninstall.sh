#!/usr/bin/env bash
# Uninstall script for act on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting act uninstallation on macOS..."
    if brew list act &> /dev/null 2>&1; then brew uninstall act; fi
    log_success "act uninstalled"
    exit 0
}

main "$@"
