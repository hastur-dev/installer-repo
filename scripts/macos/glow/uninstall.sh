#!/usr/bin/env bash
# Uninstall script for glow on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting glow uninstallation on macOS..."
    if brew list glow &> /dev/null 2>&1; then brew uninstall glow; fi
    log_success "glow uninstalled"
    exit 0
}

main "$@"
