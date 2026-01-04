#!/usr/bin/env bash
# Uninstall script for pip on Linux
# Note: pip is often a critical dependency, this script provides warnings

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly SUPPORTED_PACKAGE_MANAGERS=("apt-get" "dnf" "yum" "pacman")

# Logging functions
log_info() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_info: message cannot be empty" >&2
        return 1
    fi
    echo "[INFO] ${SCRIPT_NAME}: ${message}"
}

log_error() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_error: message cannot be empty" >&2
        return 1
    fi
    echo "[ERROR] ${SCRIPT_NAME}: ${message}" >&2
}

log_success() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_success: message cannot be empty" >&2
        return 1
    fi
    echo "[SUCCESS] ${SCRIPT_NAME}: ${message}"
}

log_warn() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_warn: message cannot be empty" >&2
        return 1
    fi
    echo "[WARN] ${SCRIPT_NAME}: ${message}"
}

# Check if pip is installed
is_pip_installed() {
    if command -v pip3 &> /dev/null || command -v pip &> /dev/null; then
        return 0
    fi
    if python3 -m pip --version &> /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Main entry point
main() {
    log_info "Starting pip uninstallation check on Linux..."

    log_warn "pip is typically bundled with Python and is a critical dependency."
    log_warn "Many system tools depend on pip and Python packages."
    log_warn "This script will NOT uninstall pip to prevent system damage."
    log_info ""
    log_info "If you need to remove pip, please do so manually with care:"
    log_info "  - Debian/Ubuntu: sudo apt-get remove python3-pip"
    log_info "  - Fedora/RHEL: sudo dnf remove python3-pip"
    log_info "  - Arch: sudo pacman -R python-pip"
    log_info ""
    log_info "Consider using virtual environments (venv) instead of system pip."

    if is_pip_installed; then
        local pip_version
        if command -v pip3 &> /dev/null; then
            pip_version=$(pip3 --version 2>&1)
        elif command -v pip &> /dev/null; then
            pip_version=$(pip --version 2>&1)
        else
            pip_version=$(python3 -m pip --version 2>&1)
        fi
        log_info "Current pip installation: ${pip_version}"
    fi

    log_success "No changes made to system pip."
    exit 0
}

main "$@"
