#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting k3d uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall k3d 2>/dev/null || true
    rm -f /usr/local/bin/k3d 2>/dev/null || true
    log_success "k3d uninstalled"
}
main "$@"
