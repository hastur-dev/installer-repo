#!/usr/bin/env bash
# Uninstall script for tokei on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting tokei uninstallation on macOS..."

    if ! brew list tokei &> /dev/null 2>&1; then
        log_info "tokei is not installed via Homebrew"
        exit 0
    fi

    brew uninstall tokei
    log_success "tokei uninstalled"
    exit 0
}

main "$@"
