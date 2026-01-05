#!/usr/bin/env bash
# Uninstall script for croc on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting croc uninstallation on Linux..."

    sudo rm -f /usr/local/bin/croc 2>/dev/null || true
    rm -rf ~/.config/croc 2>/dev/null || true

    log_success "croc uninstalled"
    exit 0
}

main "$@"
