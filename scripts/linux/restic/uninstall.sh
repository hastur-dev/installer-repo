#!/usr/bin/env bash
# Uninstall script for restic on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting restic uninstallation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo apt-get remove -y restic 2>/dev/null || true
    fi
    if command -v dnf &> /dev/null; then
        sudo dnf remove -y restic 2>/dev/null || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -R --noconfirm restic 2>/dev/null || true
    fi
    sudo rm -f /usr/local/bin/restic 2>/dev/null || true

    log_success "restic uninstalled"
    exit 0
}

main "$@"
