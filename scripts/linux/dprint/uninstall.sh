#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dprint uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall dprint 2>/dev/null || true
    command -v cargo &> /dev/null && cargo uninstall dprint 2>/dev/null || true
    rm -rf "$HOME/.dprint" 2>/dev/null || true
    log_success "dprint uninstalled"
}
main "$@"
