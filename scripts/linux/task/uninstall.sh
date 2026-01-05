#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting task uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall go-task 2>/dev/null || true
    command -v snap &> /dev/null && snap remove task 2>/dev/null || true
    rm -f /usr/local/bin/task 2>/dev/null || true
    log_success "task uninstalled"
}
main "$@"
