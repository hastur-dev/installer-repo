#!/usr/bin/env bash
# Install script for lsd on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting lsd installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y && sudo apt-get install -y lsd 2>&1 || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf install -y lsd 2>&1 || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm lsd 2>&1 || true
    fi

    if ! command -v lsd &> /dev/null && command -v cargo &> /dev/null; then
        cargo install lsd --locked 2>&1
    fi

    if ! command -v lsd &> /dev/null; then
        log_error "lsd command not found"
        exit 1
    fi
    log_success "lsd verified: $(lsd --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
