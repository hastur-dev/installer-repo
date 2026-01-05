#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dagger uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall dagger/tap/dagger 2>/dev/null || true
    rm -f /usr/local/bin/dagger 2>/dev/null || true
    log_success "dagger uninstalled"
}
main "$@"
