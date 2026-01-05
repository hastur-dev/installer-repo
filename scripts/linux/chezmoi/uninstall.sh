#!/usr/bin/env bash
# Uninstall script for chezmoi on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting chezmoi uninstallation on Linux..."

    command -v snap &> /dev/null && snap remove chezmoi 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall chezmoi 2>/dev/null || true
    rm -f /usr/local/bin/chezmoi 2>/dev/null || true

    log_success "chezmoi uninstalled"
    exit 0
}

main "$@"
