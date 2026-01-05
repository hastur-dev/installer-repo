#!/usr/bin/env bash
# Uninstall script for vegeta on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vegeta uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall vegeta 2>/dev/null || true
    rm -f /usr/local/bin/vegeta 2>/dev/null || true
    rm -f "$(go env GOPATH)/bin/vegeta" 2>/dev/null || true

    log_success "vegeta uninstalled"
    exit 0
}

main "$@"
