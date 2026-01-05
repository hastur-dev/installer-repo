#!/usr/bin/env bash
# Uninstall script for yq on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting yq uninstallation on Linux..."

    if command -v snap &> /dev/null; then
        sudo snap remove yq 2>/dev/null || true
    fi
    if command -v apt-get &> /dev/null; then
        sudo apt-get remove -y yq 2>/dev/null || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf remove -y yq 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm yq 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/yq 2>/dev/null || true

    log_success "yq uninstalled"
    exit 0
}

main "$@"
