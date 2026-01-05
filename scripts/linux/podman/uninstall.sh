#!/usr/bin/env bash
# Uninstall script for podman on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting podman uninstallation on Linux..."

    command -v apt-get &> /dev/null && apt-get remove -y -qq podman 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q podman 2>/dev/null || true
    command -v pacman &> /dev/null && pacman -Rs --noconfirm podman 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall podman 2>/dev/null || true

    log_success "podman uninstalled"
    exit 0
}

main "$@"
