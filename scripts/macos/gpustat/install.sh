#!/usr/bin/env bash
# Install script for gpustat on macOS
# gpustat is a Python package for GPU monitoring

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-macos.sh"
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
    log_info "Checking for Python installation..."

    if command -v python3 &> /dev/null; then
        local python_version
        python_version=$(python3 --version 2>&1)
        log_info "Found Python: ${python_version}"
        echo "python3"
        return 0
    fi

    if command -v python &> /dev/null; then
        local python_version
        python_version=$(python --version 2>&1)
        log_info "Found Python: ${python_version}"
        echo "python"
        return 0
    fi

    log_error "Python is not installed"
    return 1
}

# Check if pip is installed
check_pip() {
    local python_cmd="$1"

    if [ -z "$python_cmd" ]; then
        log_error "python_cmd parameter is required"
        return 1
    fi

    log_info "Checking for pip installation..."

    if "$python_cmd" -m pip --version &> /dev/null; then
        local pip_version
        pip_version=$("$python_cmd" -m pip --version 2>&1)
        log_info "Found pip: ${pip_version}"
        return 0
    fi

    log_error "pip is not installed"
    return 1
}

# Install gpustat with retry
install_gpustat() {
    local python_cmd="$1"

    if [ -z "$python_cmd" ]; then
        log_error "python_cmd parameter is required"
        return 1
    fi

    log_info "Installing gpustat via pip..."
    log_info "Note: gpustat requires NVIDIA GPUs, limited functionality on macOS"

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if "$python_cmd" -m pip install --user gpustat 2>&1; then
            log_success "gpustat installed successfully"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install gpustat after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying gpustat installation..."

    # Add user bin to PATH if needed
    export PATH="$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"

    if ! command -v gpustat &> /dev/null; then
        log_error "gpustat command not found after installation"
        return 1
    fi

    local gpustat_version
    gpustat_version=$(gpustat --version 2>&1 || echo "version check failed")

    log_success "gpustat verified: ${gpustat_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting gpustat installation on macOS..."

    verify_macos

    local python_cmd
    python_cmd=$(check_python)

    if [ -z "$python_cmd" ]; then
        log_error "Python is required but not installed"
        exit 1
    fi

    check_pip "$python_cmd"
    install_gpustat "$python_cmd"
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
