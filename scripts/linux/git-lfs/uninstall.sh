#!/usr/bin/env bash
# Uninstall script for git-lfs on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting git-lfs uninstallation on Linux..."

    git lfs uninstall 2>/dev/null || true
    command -v apt-get &> /dev/null && apt-get remove -y -qq git-lfs 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q git-lfs 2>/dev/null || true
    command -v pacman &> /dev/null && pacman -Rs --noconfirm git-lfs 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall git-lfs 2>/dev/null || true

    log_success "git-lfs uninstalled"
    exit 0
}

main "$@"
