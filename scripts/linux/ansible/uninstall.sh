#!/usr/bin/env bash
# Uninstall script for ansible on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ansible uninstallation on Linux..."

    command -v apt-get &> /dev/null && apt-get remove -y -qq ansible 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q ansible 2>/dev/null || true
    command -v pip3 &> /dev/null && pip3 uninstall -y ansible 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall ansible 2>/dev/null || true

    log_success "ansible uninstalled"
    exit 0
}

main "$@"
