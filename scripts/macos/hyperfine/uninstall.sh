#!/usr/bin/env bash
# Uninstall script for hyperfine on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hyperfine uninstallation on macOS..."
    if ! brew list hyperfine &> /dev/null 2>&1; then
        log_info "hyperfine is not installed"
        exit 0
    fi
    brew uninstall hyperfine
    log_success "hyperfine uninstalled"
    exit 0
}

main "$@"
