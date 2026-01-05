#!/usr/bin/env bash
# Uninstall script for shfmt on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting shfmt uninstallation on Linux..."

    command -v snap &> /dev/null && snap remove shfmt 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall shfmt 2>/dev/null || true
    rm -f /usr/local/bin/shfmt 2>/dev/null || true
    rm -f "$(go env GOPATH)/bin/shfmt" 2>/dev/null || true

    log_success "shfmt uninstalled"
    exit 0
}

main "$@"
