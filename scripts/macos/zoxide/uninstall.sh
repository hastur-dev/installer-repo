#!/usr/bin/env bash
# Uninstall script for zoxide on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting zoxide uninstallation on macOS..."

    if ! brew list zoxide &> /dev/null 2>&1; then
        log_info "zoxide is not installed via Homebrew"
        exit 0
    fi

    brew uninstall zoxide
    log_success "zoxide uninstalled"
    log_info "Remember to remove zoxide init from your shell config"
    exit 0
}

main "$@"
