#!/usr/bin/env bash
# Uninstall script for xsv on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting xsv uninstallation on macOS..."
    if brew list xsv &> /dev/null 2>&1; then brew uninstall xsv; fi
    log_success "xsv uninstalled"
    exit 0
}

main "$@"
