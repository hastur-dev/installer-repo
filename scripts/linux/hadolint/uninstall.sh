#!/usr/bin/env bash
# Uninstall script for hadolint on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hadolint uninstallation on Linux..."

    command -v brew &> /dev/null && brew uninstall hadolint 2>/dev/null || true
    rm -f /usr/local/bin/hadolint 2>/dev/null || true

    log_success "hadolint uninstalled"
    exit 0
}

main "$@"
