#!/usr/bin/env bash
# Uninstall script for hyperfine on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hyperfine uninstallation on Linux..."

    if ! command -v hyperfine &> /dev/null; then
        log_info "hyperfine is not installed"
        exit 0
    fi

    if command -v apt-get &> /dev/null; then sudo apt-get remove -y hyperfine 2>&1 || true; fi
    if command -v dnf &> /dev/null; then sudo dnf remove -y hyperfine 2>&1 || true; fi
    if command -v pacman &> /dev/null; then sudo pacman -R --noconfirm hyperfine 2>&1 || true; fi
    if command -v cargo &> /dev/null; then cargo uninstall hyperfine 2>&1 || true; fi

    log_success "hyperfine uninstalled"
    exit 0
}

main "$@"
