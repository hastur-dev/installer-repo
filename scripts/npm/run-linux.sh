#!/usr/bin/env bash
# Run script for npm on Linux
# Verifies installation and displays npm info

set -euo pipefail

# Constants
readonly SCRIPT_NAME="run-linux.sh"

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

# Find npm executable
find_npm() {
    log_info "Searching for npm executable..."

    if command -v npm &> /dev/null; then
        local npm_path
        npm_path=$(command -v npm)
        log_info "Found npm at: ${npm_path}"
        echo "$npm_path"
        return 0
    fi

    log_error "npm executable not found"
    return 1
}

# Get npm version
get_npm_version() {
    local npm_path="$1"

    if [ -z "$npm_path" ]; then
        log_error "npm_path parameter is required"
        return 1
    fi

    local version
    version=$("$npm_path" --version 2>&1)

    if [ -z "$version" ]; then
        log_error "Could not retrieve npm version"
        return 1
    fi

    echo "$version"
}

# Run npm smoke test
run_smoke_test() {
    local npm_path="$1"

    if [ -z "$npm_path" ]; then
        log_error "npm_path parameter is required"
        return 1
    fi

    log_info "Running npm smoke test..."

    if "$npm_path" config list 2>&1; then
        log_success "npm smoke test passed - config accessible"
        return 0
    else
        log_error "npm smoke test failed"
        return 1
    fi
}

# Display npm help summary
display_help_summary() {
    local npm_path="$1"

    if [ -z "$npm_path" ]; then
        log_error "npm_path parameter is required"
        return 1
    fi

    log_info "npm help summary:"
    "$npm_path" --help 2>&1 | head -n15 || true
}

# Main entry point
main() {
    log_info "Running npm verification on Linux..."

    local npm_path
    npm_path=$(find_npm)

    if [ -z "$npm_path" ]; then
        log_error "npm not found - please run install-linux.sh first"
        exit 1
    fi

    local version
    version=$(get_npm_version "$npm_path")
    log_success "npm version: v${version}"

    local node_version
    node_version=$(node --version 2>&1)
    log_success "Node.js version: ${node_version}"

    run_smoke_test "$npm_path"
    display_help_summary "$npm_path"

    log_success "npm is ready to use!"
    exit 0
}

main "$@"
