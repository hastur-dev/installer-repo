#!/usr/bin/env bash
# Install script for delta on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting delta installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get update -y && sudo apt-get install -y git-delta 2>&1 || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf install -y git-delta 2>&1 || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm git-delta 2>&1 || true
    fi

    if ! command -v delta &> /dev/null && command -v cargo &> /dev/null; then
        cargo install git-delta --locked 2>&1
    fi

    if ! command -v delta &> /dev/null; then
        log_error "delta command not found"
        exit 1
    fi
    log_success "delta verified: $(delta --version)"
    log_info "Configure git: git config --global core.pager delta"
    log_success "Installation complete!"
    exit 0
}

main "$@"
