#!/usr/bin/env bash
# Uninstall script for shellcheck on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting shellcheck uninstallation on Linux..."

    command -v apt-get &> /dev/null && apt-get remove -y -qq shellcheck 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q ShellCheck 2>/dev/null || true
    command -v pacman &> /dev/null && pacman -Rs --noconfirm shellcheck 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall shellcheck 2>/dev/null || true

    log_success "shellcheck uninstalled"
    exit 0
}

main "$@"
