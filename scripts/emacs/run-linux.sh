#!/usr/bin/env bash
# Run script for Emacs on Linux
# Verifies installation and runs emacs with version check

set -euo pipefail

# Constants
readonly SCRIPT_NAME="run-linux.sh"
readonly MAX_SEARCH_PATHS=20
readonly EMACS_EXPECTED_PATHS=("/usr/bin/emacs" "/usr/local/bin/emacs" "/bin/emacs")

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

# Find emacs executable
find_emacs() {
    log_info "Searching for Emacs executable..."

    if command -v emacs &> /dev/null; then
        local emacs_path
        emacs_path=$(command -v emacs)
        log_info "Found emacs at: ${emacs_path}"
        echo "$emacs_path"
        return 0
    fi

    local iteration=0
    for path in "${EMACS_EXPECTED_PATHS[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt $MAX_SEARCH_PATHS ]; then
            log_error "Exceeded search iteration limit"
            return 1
        fi

        if [ -x "$path" ]; then
            log_info "Found emacs at: ${path}"
            echo "$path"
            return 0
        fi
    done

    log_error "Emacs executable not found"
    return 1
}

# Get emacs version
get_emacs_version() {
    local emacs_path="$1"

    if [ -z "$emacs_path" ]; then
        log_error "emacs_path parameter is required"
        return 1
    fi
    if [ ! -x "$emacs_path" ]; then
        log_error "emacs_path must be executable: ${emacs_path}"
        return 1
    fi

    local version
    version=$("$emacs_path" --version 2>&1 | head -n1)

    if [ -z "$version" ]; then
        log_error "Could not retrieve Emacs version"
        return 1
    fi

    echo "$version"
}

# Run emacs smoke test
run_smoke_test() {
    local emacs_path="$1"

    if [ -z "$emacs_path" ]; then
        log_error "emacs_path parameter is required"
        return 1
    fi

    log_info "Running Emacs smoke test..."

    # Run emacs in batch mode to verify it works
    if "$emacs_path" --batch --eval "(message \"Emacs smoke test passed\")" 2>&1; then
        log_success "Emacs smoke test passed - batch mode works"
        return 0
    else
        log_error "Emacs smoke test failed"
        return 1
    fi
}

# Display emacs help summary
display_help_summary() {
    local emacs_path="$1"

    if [ -z "$emacs_path" ]; then
        log_error "emacs_path parameter is required"
        return 1
    fi

    log_info "Emacs help summary:"
    "$emacs_path" --help 2>&1 | head -n10 || true
}

# Main entry point
main() {
    log_info "Running Emacs verification on Linux..."

    local emacs_path
    emacs_path=$(find_emacs)

    if [ -z "$emacs_path" ]; then
        log_error "Emacs not found - please run install-linux.sh first"
        exit 1
    fi

    local version
    version=$(get_emacs_version "$emacs_path")
    log_success "Emacs version: ${version}"

    run_smoke_test "$emacs_path"
    display_help_summary "$emacs_path"

    log_success "Emacs is ready to use!"
    exit 0
}

main "$@"
