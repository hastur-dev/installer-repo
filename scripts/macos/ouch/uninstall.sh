#!/usr/bin/env bash
# Uninstall script for ouch on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ouch uninstallation on macOS..."
    if brew list ouch &> /dev/null 2>&1; then brew uninstall ouch; fi
    log_success "ouch uninstalled"
    exit 0
}

main "$@"
