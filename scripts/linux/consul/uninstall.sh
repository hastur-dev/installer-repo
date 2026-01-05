#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting consul uninstallation on Linux..."
    command -v apt-get &> /dev/null && apt-get remove -y -qq consul 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall consul 2>/dev/null || true
    log_success "consul uninstalled"
}
main "$@"
