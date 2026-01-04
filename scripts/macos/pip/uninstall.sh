#!/usr/bin/env bash
# Uninstall script for pip on macOS
# Note: pip comes with Python, so this would require uninstalling Python

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-macos.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2

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

# Check if running on macOS
verify_macos() {
    log_info "Verifying macOS environment..."
    local os_type
    os_type=$(uname -s)
    if [ "$os_type" != "Darwin" ]; then
        log_error "This script requires macOS (detected: ${os_type})"
        return 1
    fi
    log_info "Confirmed macOS environment"
    return 0
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
    log_info "Starting pip uninstallation check on macOS..."

    verify_macos

    log_warn "pip is bundled with Python and cannot be uninstalled separately."
    log_warn "To remove pip, you would need to uninstall Python."
    log_warn "This script will NOT uninstall pip/Python to prevent issues."
    log_info ""
    log_info "If you need to remove Python (and thus pip), use:"
    log_info "  brew uninstall python"
    log_info ""
    log_info "Note: System Python (/usr/bin/python3) cannot be removed."
    log_info "Consider using virtual environments (venv) instead."

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

    log_success "No changes made to pip."
    exit 0
}

main "$@"
