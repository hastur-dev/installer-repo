#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ttyd uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall ttyd 2>/dev/null || true
    command -v snap &> /dev/null && snap remove ttyd 2>/dev/null || true
    log_success "ttyd uninstalled"
}
main "$@"
