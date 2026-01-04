#!/usr/bin/env bash
# Uninstall script for Starship on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall-linux.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting Starship uninstallation on Linux..."

    if ! command -v starship &> /dev/null; then
        log_info "Starship is not installed"
        exit 0
    fi

    log_info "Removing Starship binary..."
    sudo rm -f /usr/local/bin/starship 2>/dev/null || rm -f ~/.local/bin/starship 2>/dev/null || true

    if command -v starship &> /dev/null; then
        log_error "Starship is still installed"
        exit 1
    fi

    log_success "Starship uninstalled"
    log_info "Remember to remove 'eval \"\$(starship init ...)\"' from your shell config"
    exit 0
}

main "$@"
