#!/usr/bin/env bash
# Uninstall script for Python on Linux
# Note: Be careful as Python is often a system dependency

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

# Detect package manager
detect_package_manager() {
    local detected=""
    local iteration=0

    for pm in "${SUPPORTED_PACKAGE_MANAGERS[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt 10 ]; then
            log_error "Exceeded iteration limit in detect_package_manager"
            return 1
        fi

        if command -v "$pm" &> /dev/null; then
            detected="$pm"
            break
        fi
    done

    if [ -z "$detected" ]; then
        log_error "No supported package manager found"
        return 1
    fi

    echo "$detected"
}

# Check if Python is installed
is_python_installed() {
    if command -v python3 &> /dev/null; then
        return 0
    fi
    return 1
}

# Main entry point
main() {
    log_info "Starting Python uninstallation check on Linux..."

    log_warn "Python is typically a critical system dependency on Linux."
    log_warn "Uninstalling Python may break your system."
    log_warn "This script will NOT uninstall Python to prevent system damage."
    log_info ""
    log_info "If you need to remove Python, please do so manually with care:"
    log_info "  - Debian/Ubuntu: sudo apt-get remove python3"
    log_info "  - Fedora/RHEL: sudo dnf remove python3"
    log_info "  - Arch: sudo pacman -R python"
    log_info ""
    log_info "Consider using virtual environments (venv) instead of system Python."

    if is_python_installed; then
        local python_version
        python_version=$(python3 --version 2>&1)
        log_info "Current Python installation: ${python_version}"
    fi

    log_success "No changes made to system Python."
    exit 0
}

main "$@"
