#!/usr/bin/env bash
# Uninstall script for sops on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting sops uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall sops 2>/dev/null || true
    rm -f /usr/local/bin/sops 2>/dev/null || true

    log_success "sops uninstalled"
    exit 0
}

main "$@"
