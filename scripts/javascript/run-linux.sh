#!/usr/bin/env bash
# Run script for JavaScript (Node.js) on Linux
# Verifies installation and displays Node.js info

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

# Find node executable
find_node() {
    log_info "Searching for Node.js executable..."

    if command -v node &> /dev/null; then
        local node_path
        node_path=$(command -v node)
        log_info "Found node at: ${node_path}"
        echo "$node_path"
        return 0
    fi

    log_error "Node.js executable not found"
    return 1
}

# Get node version
get_node_version() {
    local node_path="$1"

    if [ -z "$node_path" ]; then
        log_error "node_path parameter is required"
        return 1
    fi

    local version
    version=$("$node_path" --version 2>&1)

    if [ -z "$version" ]; then
        log_error "Could not retrieve Node.js version"
        return 1
    fi

    echo "$version"
}

# Run node smoke test
run_smoke_test() {
    local node_path="$1"

    if [ -z "$node_path" ]; then
        log_error "node_path parameter is required"
        return 1
    fi

    log_info "Running JavaScript smoke test..."

    if "$node_path" -e "console.log('Hello from JavaScript!')" 2>&1; then
        log_success "JavaScript smoke test passed"
        return 0
    else
        log_error "JavaScript smoke test failed"
        return 1
    fi
}

# Display node info
display_node_info() {
    local node_path="$1"

    if [ -z "$node_path" ]; then
        log_error "node_path parameter is required"
        return 1
    fi

    log_info "Node.js info:"
    "$node_path" -e "console.log('Platform:', process.platform); console.log('Arch:', process.arch); console.log('Version:', process.version)" 2>&1 || true

    log_info "npm version:"
    npm --version 2>&1 || log_info "npm not available"

    log_info "Node.js help:"
    "$node_path" --help 2>&1 | head -n10 || true
}

# Main entry point
main() {
    log_info "Running JavaScript (Node.js) verification on Linux..."

    local node_path
    node_path=$(find_node)

    if [ -z "$node_path" ]; then
        log_error "Node.js not found - please run install-linux.sh first"
        exit 1
    fi

    local version
    version=$(get_node_version "$node_path")
    log_success "Node.js version: ${version}"

    run_smoke_test "$node_path"
    display_node_info "$node_path"

    log_success "JavaScript (Node.js) is ready to use!"
    exit 0
}

main "$@"
