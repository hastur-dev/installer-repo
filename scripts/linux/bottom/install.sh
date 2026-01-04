#!/usr/bin/env bash
# Install script for bottom on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting bottom installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y && sudo apt-get install -y bottom 2>&1 || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf install -y bottom 2>&1 || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm bottom 2>&1 || true
    fi

    if ! command -v btm &> /dev/null && command -v cargo &> /dev/null; then
        cargo install bottom --locked 2>&1
    fi

    if ! command -v btm &> /dev/null; then
        log_error "btm command not found"
        exit 1
    fi
    log_success "bottom verified: $(btm --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
