#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting pipx uninstallation on Linux..."
    command -v apt-get &> /dev/null && apt-get remove -y -qq pipx 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q pipx 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall pipx 2>/dev/null || true
    pip3 uninstall -y pipx 2>/dev/null || true
    log_success "pipx uninstalled"
}
main "$@"
