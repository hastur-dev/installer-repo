#!/usr/bin/env bash
# Run script for gpustat on macOS
# Verifies installation and displays GPU status

set -euo pipefail

# Constants
readonly SCRIPT_NAME="run-macos.sh"

# Logging functions
log_info() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_info: message cannot be empty" >&2
        return 1
    fi
    echo "[INFO] ${SCRIPT_NAME}: ${message}" >&2
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
    echo "[SUCCESS] ${SCRIPT_NAME}: ${message}" >&2
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

# Find gpustat executable
find_gpustat() {
    log_info "Searching for gpustat executable..."

    export PATH="$HOME/.local/bin:$HOME/Library/Python/3.*/bin:$PATH"

    if command -v gpustat &> /dev/null; then
        local gpustat_path
        gpustat_path=$(command -v gpustat)
        log_info "Found gpustat at: ${gpustat_path}"
        echo "$gpustat_path"
        return 0
    fi

    log_error "gpustat executable not found"
    return 1
}

# Get gpustat version
get_gpustat_version() {
    local gpustat_path="$1"

    if [ -z "$gpustat_path" ]; then
        log_error "gpustat_path parameter is required"
        return 1
    fi

    local version
    version=$("$gpustat_path" --version 2>&1 || echo "unknown")

    echo "$version"
}

# Run gpustat
run_gpustat() {
    local gpustat_path="$1"

    if [ -z "$gpustat_path" ]; then
        log_error "gpustat_path parameter is required"
        return 1
    fi

    log_info "Running gpustat..."
    log_info "Note: gpustat requires NVIDIA GPUs, limited functionality on macOS"

    if "$gpustat_path" 2>&1; then
        log_success "gpustat executed successfully"
        return 0
    else
        log_info "gpustat returned non-zero (expected on macOS without NVIDIA GPU)"
        return 0
    fi
}

# Display help
display_help() {
    local gpustat_path="$1"

    if [ -z "$gpustat_path" ]; then
        log_error "gpustat_path parameter is required"
        return 1
    fi

    log_info "gpustat help:"
    "$gpustat_path" --help 2>&1 | head -n15 || true
}

# Main entry point
main() {
    log_info "Running gpustat verification on macOS..."

    verify_macos

    local gpustat_path
    gpustat_path=$(find_gpustat)

    if [ -z "$gpustat_path" ]; then
        log_error "gpustat not found - please run install-macos.sh first"
        exit 1
    fi

    local version
    version=$(get_gpustat_version "$gpustat_path")
    log_success "gpustat version: ${version}"

    run_gpustat "$gpustat_path"
    display_help "$gpustat_path"

    log_success "gpustat is ready to use!"
    exit 0
}

main "$@"
