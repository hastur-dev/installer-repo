#!/usr/bin/env bash
# Install script for xsv on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting xsv installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm xsv 2>&1 || true
    fi

    if ! command -v xsv &> /dev/null && command -v cargo &> /dev/null; then
        cargo install xsv --locked 2>&1
    fi

    if ! command -v xsv &> /dev/null; then
        log_error "xsv command not found"
        exit 1
    fi
    log_success "xsv verified: $(xsv --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
