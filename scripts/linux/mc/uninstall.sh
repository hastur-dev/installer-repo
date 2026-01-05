#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mc uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall minio/stable/mc 2>/dev/null || true
    rm -f /usr/local/bin/mc 2>/dev/null || true
    log_success "mc uninstalled"
}
main "$@"
