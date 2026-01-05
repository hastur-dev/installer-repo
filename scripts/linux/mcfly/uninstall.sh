#!/usr/bin/env bash
# Uninstall script for mcfly on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mcfly uninstallation on Linux..."

    if command -v cargo &> /dev/null; then
        cargo uninstall mcfly 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm mcfly 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/mcfly 2>/dev/null || true
    rm -rf ~/.mcfly 2>/dev/null || true

    log_success "mcfly uninstalled"
    log_info "Remember to remove mcfly init from your shell config"
    exit 0
}

main "$@"
