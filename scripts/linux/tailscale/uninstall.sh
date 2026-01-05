#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting tailscale uninstallation on Linux..."
    command -v apt-get &> /dev/null && apt-get remove -y -qq tailscale 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q tailscale 2>/dev/null || true
    log_success "tailscale uninstalled"
}
main "$@"
