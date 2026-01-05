#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting tailscale installation on Linux..."

    curl -fsSL https://tailscale.com/install.sh | sh

    if command -v tailscale &> /dev/null; then
        log_success "tailscale installed: $(tailscale version 2>&1 | head -1)"
    else
        log_error "Failed to install tailscale"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
