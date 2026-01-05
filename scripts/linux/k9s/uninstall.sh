#!/usr/bin/env bash
# Uninstall script for k9s on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting k9s uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall k9s 2>/dev/null || true
    command -v snap &> /dev/null && snap remove k9s 2>/dev/null || true
    rm -f /usr/local/bin/k9s 2>/dev/null || true

    log_success "k9s uninstalled"
    exit 0
}

main "$@"
