#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vhs uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall vhs 2>/dev/null || true
    rm -f "$(go env GOPATH 2>/dev/null)/bin/vhs" 2>/dev/null || true
    log_success "vhs uninstalled"
}
main "$@"
