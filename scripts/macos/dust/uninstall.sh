#!/usr/bin/env bash
# Uninstall script for dust on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dust uninstallation on macOS..."
    if brew list dust &> /dev/null 2>&1; then brew uninstall dust; fi
    log_success "dust uninstalled"
    exit 0
}

main "$@"
