#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting uv uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall uv 2>/dev/null || true
    rm -f "$HOME/.cargo/bin/uv" 2>/dev/null || true
    log_success "uv uninstalled"
}
main "$@"
