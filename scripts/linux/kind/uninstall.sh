#!/usr/bin/env bash
# Uninstall script for kind on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting kind uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall kind 2>/dev/null || true
    rm -f /usr/local/bin/kind 2>/dev/null || true
    rm -f "$(go env GOPATH)/bin/kind" 2>/dev/null || true

    log_success "kind uninstalled"
    exit 0
}

main "$@"
