#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting biome uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall biome 2>/dev/null || true
    command -v npm &> /dev/null && npm uninstall -g @biomejs/biome 2>/dev/null || true
    command -v cargo &> /dev/null && cargo uninstall biome_cli 2>/dev/null || true
    log_success "biome uninstalled"
}
main "$@"
