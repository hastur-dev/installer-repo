#!/usr/bin/env bash
# Uninstall script for Starship on macOS

set -euo pipefail

readonly SCRIPT_NAME="uninstall-macos.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting Starship uninstallation on macOS..."

    if ! brew list starship &> /dev/null 2>&1; then
        log_info "Starship is not installed via Homebrew"
        exit 0
    fi

    brew uninstall starship
    log_success "Starship uninstalled"
    log_info "Remember to remove 'eval \"\$(starship init ...)\"' from your shell config"
    exit 0
}

main "$@"
