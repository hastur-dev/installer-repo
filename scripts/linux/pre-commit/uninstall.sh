#!/usr/bin/env bash
# Uninstall script for pre-commit on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting pre-commit uninstallation on Linux..."

    command -v pip3 &> /dev/null && pip3 uninstall -y pre-commit 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall pre-commit 2>/dev/null || true
    command -v apt-get &> /dev/null && apt-get remove -y -qq pre-commit 2>/dev/null || true

    log_success "pre-commit uninstalled"
    exit 0
}

main "$@"
