#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting alacritty installation on Linux..."
    local installed=false

    if command -v apt-get &> /dev/null; then
        apt-get update -qq && apt-get install -y -qq alacritty && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v dnf &> /dev/null; then
        dnf install -y -q alacritty && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v snap &> /dev/null; then
        snap install alacritty --classic && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install --cask alacritty && installed=true
    fi

    if command -v alacritty &> /dev/null; then
        log_success "alacritty installed: $(alacritty --version 2>&1)"
    else
        log_error "Failed to install alacritty"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
