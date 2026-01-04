#!/usr/bin/env bash
# Install script for act on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting act installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm act 2>&1 || true
    fi

    if ! command -v act &> /dev/null; then
        # Use official installer
        curl -fsSL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash 2>&1
    fi

    if ! command -v act &> /dev/null; then
        log_error "act command not found"
        exit 1
    fi
    log_success "act verified: $(act --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
