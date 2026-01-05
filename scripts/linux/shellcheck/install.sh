#!/usr/bin/env bash
# Install script for shellcheck on Linux (shell script linter)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting shellcheck installation on Linux..."

    local installed=false

    # Try apt (Debian/Ubuntu)
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq shellcheck && installed=true
    fi

    # Try dnf (Fedora/RHEL)
    if [[ "$installed" == "false" ]] && command -v dnf &> /dev/null; then
        dnf install -y -q ShellCheck && installed=true
    fi

    # Try pacman (Arch)
    if [[ "$installed" == "false" ]] && command -v pacman &> /dev/null; then
        pacman -S --noconfirm shellcheck && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install shellcheck && installed=true
    fi

    if command -v shellcheck &> /dev/null; then
        log_success "shellcheck installed: $(shellcheck --version 2>&1 | grep version)"
    else
        log_error "Failed to install shellcheck"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
