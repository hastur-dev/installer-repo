#!/usr/bin/env bash
# Install script for pre-commit on Linux (git hook manager)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting pre-commit installation on Linux..."

    local installed=false

    # Try pip
    if command -v pip3 &> /dev/null; then
        pip3 install --quiet pre-commit && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install pre-commit && installed=true
    fi

    # Try apt (Debian/Ubuntu)
    if [[ "$installed" == "false" ]] && command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq pre-commit && installed=true
    fi

    if command -v pre-commit &> /dev/null; then
        log_success "pre-commit installed: $(pre-commit --version 2>&1)"
    else
        log_error "Failed to install pre-commit"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
