#!/usr/bin/env bash
# Install script for watchexec on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting watchexec installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm watchexec 2>&1 || true
    fi

    if ! command -v watchexec &> /dev/null && command -v cargo &> /dev/null; then
        cargo install watchexec-cli --locked 2>&1
    fi

    if ! command -v watchexec &> /dev/null; then
        log_error "watchexec command not found"
        exit 1
    fi
    log_success "watchexec verified: $(watchexec --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
