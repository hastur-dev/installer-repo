#!/usr/bin/env bash
# Uninstall script for just on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting just uninstallation on macOS..."
    if brew list just &> /dev/null 2>&1; then brew uninstall just; fi
    log_success "just uninstalled"
    exit 0
}

main "$@"
