#!/usr/bin/env bash
# Install script for gitui on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gitui installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm gitui 2>&1 || true
    fi

    if ! command -v gitui &> /dev/null && command -v cargo &> /dev/null; then
        cargo install gitui --locked 2>&1
    fi

    if ! command -v gitui &> /dev/null; then
        log_error "gitui command not found"
        exit 1
    fi
    log_success "gitui verified: $(gitui --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
