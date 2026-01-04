#!/usr/bin/env bash
# Install script for atuin on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting atuin installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm atuin 2>&1 || true
    fi

    if ! command -v atuin &> /dev/null && command -v cargo &> /dev/null; then
        cargo install atuin --locked 2>&1
    fi

    if ! command -v atuin &> /dev/null; then
        log_error "atuin command not found"
        exit 1
    fi
    log_success "atuin verified: $(atuin --version)"
    log_info "Run 'atuin init <shell>' to configure shell integration"
    log_success "Installation complete!"
    exit 0
}

main "$@"
