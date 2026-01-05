#!/usr/bin/env bash
# Uninstall script for hugo on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hugo uninstallation on Linux..."

    command -v snap &> /dev/null && snap remove hugo 2>/dev/null || true
    command -v apt-get &> /dev/null && apt-get remove -y -qq hugo 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall hugo 2>/dev/null || true
    rm -f "$(go env GOPATH)/bin/hugo" 2>/dev/null || true

    log_success "hugo uninstalled"
    exit 0
}

main "$@"
