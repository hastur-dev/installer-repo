#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting wezterm uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall --cask wezterm 2>/dev/null || true
    command -v flatpak &> /dev/null && flatpak uninstall -y org.wezfurlong.wezterm 2>/dev/null || true
    log_success "wezterm uninstalled"
}
main "$@"
