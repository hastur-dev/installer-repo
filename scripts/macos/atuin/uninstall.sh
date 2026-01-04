#!/usr/bin/env bash
# Uninstall script for atuin on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting atuin uninstallation on macOS..."
    if brew list atuin &> /dev/null 2>&1; then brew uninstall atuin; fi
    log_success "atuin uninstalled"
    log_info "Remember to remove atuin init from your shell config"
    exit 0
}

main "$@"
