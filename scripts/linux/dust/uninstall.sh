#!/usr/bin/env bash
# Uninstall script for dust on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dust uninstallation on Linux..."

    if command -v apt-get &> /dev/null; then sudo apt-get remove -y du-dust 2>&1 || true; fi
    if command -v dnf &> /dev/null; then sudo dnf remove -y dust 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm dust 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall du-dust 2>&1 || true; fi

    log_success "dust uninstalled"
    exit 0
}

main "$@"
