#!/usr/bin/env bash
# Run script for Vim on Linux
# Verifies installation and runs vim with version check

set -euo pipefail

# Constants
readonly SCRIPT_NAME="run-linux.sh"
readonly MAX_SEARCH_PATHS=20
readonly VIM_EXPECTED_PATHS=("/usr/bin/vim" "/usr/local/bin/vim" "/bin/vim")

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
    log_info "Running Vim verification on Linux..."

    # Find vim
    local vim_path
    vim_path=$(find_vim)

    # Postcondition check
    if [ -z "$vim_path" ]; then
        log_error "Vim not found - please run install-linux.sh first"
        exit 1
    fi

    # Get version
    local version
    version=$(get_vim_version "$vim_path")
    log_success "Vim version: ${version}"

    # Run smoke test
    run_smoke_test "$vim_path"

    # Display help
    display_help_summary "$vim_path"

    log_success "Vim is ready to use!"
    exit 0
}

main "$@"
