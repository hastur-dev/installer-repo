#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting zola uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall zola 2>/dev/null || true
    command -v snap &> /dev/null && snap remove zola 2>/dev/null || true
    command -v cargo &> /dev/null && cargo uninstall zola 2>/dev/null || true
    log_success "zola uninstalled"
}
main "$@"
