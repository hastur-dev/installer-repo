#!/usr/bin/env bash
# Uninstall script for act on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting act uninstallation on Linux..."
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm act 2>&1 || true; fi
    sudo rm -f /usr/local/bin/act 2>&1 || true
    log_success "act uninstalled"
    exit 0
}

main "$@"
