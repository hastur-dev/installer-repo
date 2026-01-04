#!/usr/bin/env bash
# Install script for broot on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting broot installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm broot 2>&1 || true
    fi

    if ! command -v broot &> /dev/null && command -v cargo &> /dev/null; then
        cargo install broot --locked 2>&1
    fi

    if ! command -v broot &> /dev/null; then
        log_error "broot command not found"
        exit 1
    fi
    log_success "broot verified: $(broot --version)"
    log_info "Run 'broot' once to install shell function"
    log_success "Installation complete!"
    exit 0
}

main "$@"
