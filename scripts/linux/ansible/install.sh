#!/usr/bin/env bash
# Install script for ansible on Linux (automation tool)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ansible installation on Linux..."

    local installed=false

    # Try apt (Debian/Ubuntu)
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq ansible && installed=true
    fi

    # Try dnf (Fedora/RHEL)
    if [[ "$installed" == "false" ]] && command -v dnf &> /dev/null; then
        dnf install -y -q ansible && installed=true
    fi

    # Try pip
    if [[ "$installed" == "false" ]] && command -v pip3 &> /dev/null; then
        pip3 install --quiet ansible && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install ansible && installed=true
    fi

    if command -v ansible &> /dev/null; then
        log_success "ansible installed: $(ansible --version 2>&1 | head -1)"
    else
        log_error "Failed to install ansible"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
