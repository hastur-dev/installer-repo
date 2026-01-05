#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting goreleaser uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall goreleaser 2>/dev/null || true
    command -v snap &> /dev/null && snap remove goreleaser 2>/dev/null || true
    rm -f "$(go env GOPATH 2>/dev/null)/bin/goreleaser" 2>/dev/null || true
    log_success "goreleaser uninstalled"
}
main "$@"
