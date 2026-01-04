#!/usr/bin/env bash
# Install script for procs on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting procs installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm procs 2>&1 || true
    fi

    if ! command -v procs &> /dev/null && command -v cargo &> /dev/null; then
        cargo install procs --locked 2>&1
    fi

    if ! command -v procs &> /dev/null; then
        log_error "procs command not found"
        exit 1
    fi
    log_success "procs verified: $(procs --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
