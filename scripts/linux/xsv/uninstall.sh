#!/usr/bin/env bash
# Uninstall script for xsv on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting xsv uninstallation on Linux..."
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm xsv 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall xsv 2>&1 || true; fi
    log_success "xsv uninstalled"
    exit 0
}

main "$@"
