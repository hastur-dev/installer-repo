#!/usr/bin/env bash
# Run script for Python on macOS
# Verifies installation and displays Python info

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

# Find python executable
find_python() {
    log_info "Searching for Python executable..."

    if command -v python3 &> /dev/null; then
        local python_path
        python_path=$(command -v python3)
        log_info "Found python3 at: ${python_path}"
        echo "$python_path"
        return 0
    fi

    if command -v python &> /dev/null; then
        local python_path
        python_path=$(command -v python)
        log_info "Found python at: ${python_path}"
        echo "$python_path"
        return 0
    fi

    log_error "Python executable not found"
    return 1
}

# Get python version
get_python_version() {
    local python_path="$1"

    if [ -z "$python_path" ]; then
        log_error "python_path parameter is required"
        return 1
    fi

    local version
    version=$("$python_path" --version 2>&1)

    if [ -z "$version" ]; then
        log_error "Could not retrieve Python version"
        return 1
    fi

    echo "$version"
}

# Run python smoke test
run_smoke_test() {
    local python_path="$1"

    if [ -z "$python_path" ]; then
        log_error "python_path parameter is required"
        return 1
    fi

    log_info "Running Python smoke test..."

    if "$python_path" -c "print('Hello from Python!')" 2>&1; then
        log_success "Python smoke test passed"
        return 0
    else
        log_error "Python smoke test failed"
        return 1
    fi
}

# Display python info
display_python_info() {
    local python_path="$1"

    if [ -z "$python_path" ]; then
        log_error "python_path parameter is required"
        return 1
    fi

    log_info "Python system info:"
    "$python_path" -c "import sys; print(f'Platform: {sys.platform}'); print(f'Executable: {sys.executable}'); print(f'Version: {sys.version}')" 2>&1 || true

    log_info "pip version:"
    "$python_path" -m pip --version 2>&1 || log_info "pip not available"
}

# Main entry point
main() {
    log_info "Running Python verification on macOS..."

    verify_macos

    local python_path
    python_path=$(find_python)

    if [ -z "$python_path" ]; then
        log_error "Python not found - please run install-macos.sh first"
        exit 1
    fi

    local version
    version=$(get_python_version "$python_path")
    log_success "Python version: ${version}"

    run_smoke_test "$python_path"
    display_python_info "$python_path"

    log_success "Python is ready to use!"
    exit 0
}

main "$@"
