#!/usr/bin/env bash
# Uninstall script for bottom on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting bottom uninstallation on macOS..."
    if brew list bottom &> /dev/null 2>&1; then brew uninstall bottom; fi
    log_success "bottom uninstalled"
    exit 0
}

main "$@"
