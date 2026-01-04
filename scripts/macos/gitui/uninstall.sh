#!/usr/bin/env bash
# Uninstall script for gitui on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gitui uninstallation on macOS..."
    if brew list gitui &> /dev/null 2>&1; then brew uninstall gitui; fi
    log_success "gitui uninstalled"
    exit 0
}

main "$@"
