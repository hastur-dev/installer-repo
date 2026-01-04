#!/usr/bin/env bash
# Uninstall script for hexyl on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hexyl uninstallation on macOS..."
    if brew list hexyl &> /dev/null 2>&1; then brew uninstall hexyl; fi
    log_success "hexyl uninstalled"
    exit 0
}

main "$@"
