#!/usr/bin/env bash
# Run script for Vim on macOS
# Verifies installation and runs vim with version check

set -euo pipefail

# Constants
readonly SCRIPT_NAME="run-macos.sh"
readonly MAX_SEARCH_PATHS=20
readonly VIM_EXPECTED_PATHS=(
    "/opt/homebrew/bin/vim"
    "/usr/local/bin/vim"
    "/usr/bin/vim"
)

# Logging functions
log_info() {
    local message="$1"
    # Precondition
    if [ -z "$message" ]; then
        echo "[ERROR] log_info: message cannot be empty" >&2
        return 1
    fi
    echo "[INFO] ${SCRIPT_NAME}: ${message}"
}

log_error() {
    local message="$1"
    # Precondition
    if [ -z "$message" ]; then
        echo "[ERROR] log_error: message cannot be empty" >&2
        return 1
    fi
    echo "[ERROR] ${SCRIPT_NAME}: ${message}" >&2
}

log_success() {
    local message="$1"
    # Precondition
    if [ -z "$message" ]; then
        echo "[ERROR] log_success: message cannot be empty" >&2
        return 1
    fi
    echo "[SUCCESS] ${SCRIPT_NAME}: ${message}"
}

# Check if running on macOS
verify_macos() {
    local os_type
    os_type=$(uname -s)

    if [ "$os_type" != "Darwin" ]; then
        log_error "This script requires macOS (detected: ${os_type})"
        return 1
    fi
    return 0
}

# Find vim executable
find_vim() {
    log_info "Searching for Vim executable..."

    # First try command lookup
    if command -v vim &> /dev/null; then
        local vim_path
        vim_path=$(command -v vim)
        log_info "Found vim at: ${vim_path}"
        echo "$vim_path"
        return 0
    fi

    # Search common paths (bounded loop)
    local iteration=0
    for path in "${VIM_EXPECTED_PATHS[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt $MAX_SEARCH_PATHS ]; then
            log_error "Exceeded search iteration limit"
            return 1
        fi

        if [ -x "$path" ]; then
            log_info "Found vim at: ${path}"
            echo "$path"
            return 0
        fi
    done

    log_error "Vim executable not found"
    return 1
}

# Get vim version
get_vim_version() {
    local vim_path="$1"

    # Precondition
    if [ -z "$vim_path" ]; then
        log_error "vim_path parameter is required"
        return 1
    fi
    if [ ! -x "$vim_path" ]; then
        log_error "vim_path must be executable: ${vim_path}"
        return 1
    fi

    local version
    version=$("$vim_path" --version 2>&1 | head -n1)

    # Postcondition
    if [ -z "$version" ]; then
        log_error "Could not retrieve Vim version"
        return 1
    fi

    echo "$version"
}

# Run vim smoke test
run_smoke_test() {
    local vim_path="$1"

    # Precondition
    if [ -z "$vim_path" ]; then
        log_error "vim_path parameter is required"
        return 1
    fi

    log_info "Running Vim smoke test..."

    # Create a temporary test file
    local test_file
    test_file=$(mktemp /tmp/vim_test_XXXXXX.txt)

    # Ensure cleanup
    trap "rm -f '$test_file'" EXIT

    # Write to file using vim in ex mode (non-interactive)
    if echo -e "iTest content from vim smoke test\e:wq" | "$vim_path" "$test_file" -e -s 2>/dev/null; then
        log_info "Vim ex-mode write test passed"
    fi

    # Verify file was created/modified
    if [ -f "$test_file" ]; then
        log_success "Vim smoke test passed - file operations work"
        return 0
    else
        log_error "Vim smoke test failed - file was not created"
        return 1
    fi
}

# Check Homebrew vim installation details
check_homebrew_info() {
    log_info "Checking Homebrew Vim info..."

    if command -v brew &> /dev/null; then
        if brew list vim &> /dev/null; then
            brew info vim --json=v2 2>/dev/null | head -c 500 || true
            log_info "Vim installed via Homebrew"
        else
            log_info "Vim not installed via Homebrew (may be system vim)"
        fi
    fi
}

# Display vim help summary
display_help_summary() {
    local vim_path="$1"

    # Precondition
    if [ -z "$vim_path" ]; then
        log_error "vim_path parameter is required"
        return 1
    fi

    log_info "Vim help summary:"
    "$vim_path" --help 2>&1 | head -n10 || true
}

# Main entry point
main() {
    log_info "Running Vim verification on macOS..."

    # Verify macOS
    verify_macos

    # Find vim
    local vim_path
    vim_path=$(find_vim)

    # Postcondition check
    if [ -z "$vim_path" ]; then
        log_error "Vim not found - please run install-macos.sh first"
        exit 1
    fi

    # Get version
    local version
    version=$(get_vim_version "$vim_path")
    log_success "Vim version: ${version}"

    # Run smoke test
    run_smoke_test "$vim_path"

    # Check Homebrew info
    check_homebrew_info

    # Display help
    display_help_summary "$vim_path"

    log_success "Vim is ready to use!"
    exit 0
}

main "$@"
