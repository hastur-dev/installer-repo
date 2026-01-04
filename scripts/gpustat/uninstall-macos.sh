#!/usr/bin/env bash
# Uninstall script for gpustat on macOS

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

# Check if Python is installed
check_python() {
    if command -v python3 &> /dev/null; then
        echo "python3"
        return 0
    fi
    if command -v python &> /dev/null; then
        echo "python"
        return 0
    fi
    return 1
}

# Check if gpustat is installed
is_gpustat_installed() {
    export PATH="$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"
    if command -v gpustat &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall gpustat with retry
uninstall_gpustat() {
    local python_cmd="$1"

    if [ -z "$python_cmd" ]; then
        log_error "python_cmd parameter is required"
        return 1
    fi

    log_info "Uninstalling gpustat via pip..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if "$python_cmd" -m pip uninstall -y gpustat 2>&1; then
            log_success "gpustat uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall gpustat after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying gpustat uninstallation..."

    hash -r 2>/dev/null || true

    if command -v gpustat &> /dev/null; then
        log_error "gpustat is still installed"
        return 1
    fi

    log_success "gpustat has been removed from the system"
    return 0
}

# Main entry point
main() {
    log_info "Starting gpustat uninstallation on macOS..."

    verify_macos

    if ! is_gpustat_installed; then
        log_info "gpustat is not installed, nothing to uninstall"
        exit 0
    fi

    local python_cmd
    python_cmd=$(check_python) || true

    if [ -z "$python_cmd" ]; then
        log_error "Python is required for uninstallation"
        exit 1
    fi

    uninstall_gpustat "$python_cmd"
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
