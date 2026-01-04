#!/usr/bin/env bash
# Uninstall script for broot on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting broot uninstallation on macOS..."
    if brew list broot &> /dev/null 2>&1; then brew uninstall broot; fi
    log_success "broot uninstalled"
    exit 0
}

main "$@"
