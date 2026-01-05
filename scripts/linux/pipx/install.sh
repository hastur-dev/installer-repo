#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting pipx installation on Linux..."
    local installed=false

    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq pipx && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v dnf &> /dev/null; then
        dnf install -y -q pipx && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install pipx && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v pip3 &> /dev/null; then
        pip3 install --user pipx && installed=true
    fi

    pipx ensurepath 2>/dev/null || true

    if command -v pipx &> /dev/null; then
        log_success "pipx installed: $(pipx --version 2>&1)"
    else
        log_error "Failed to install pipx"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
