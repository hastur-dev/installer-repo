#!/usr/bin/env bash
# Uninstall script for dive on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dive uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall dive 2>/dev/null || true
    command -v snap &> /dev/null && snap remove dive 2>/dev/null || true
    rm -f /usr/local/bin/dive 2>/dev/null || true

    log_success "dive uninstalled"
    exit 0
}

main "$@"
