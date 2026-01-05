#!/usr/bin/env bash
# Install script for chezmoi on Linux (dotfiles manager)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting chezmoi installation on Linux..."

    local installed=false

    # Try snap
    if command -v snap &> /dev/null; then
        snap install chezmoi --classic && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install chezmoi && installed=true
    fi

    # Official install script
    if [[ "$installed" == "false" ]]; then
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin
        installed=true
    fi

    if command -v chezmoi &> /dev/null; then
        log_success "chezmoi installed: $(chezmoi --version 2>&1)"
    else
        log_error "Failed to install chezmoi"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
