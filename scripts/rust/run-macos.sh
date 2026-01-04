#!/usr/bin/env bash
# Run script for Rust on macOS
# Verifies installation and displays Rust info

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

# Source cargo environment
source_cargo_env() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
}

# Find rustc executable
find_rustc() {
    log_info "Searching for Rust executable..."

    source_cargo_env

    if command -v rustc &> /dev/null; then
        local rustc_path
        rustc_path=$(command -v rustc)
        log_info "Found rustc at: ${rustc_path}"
        echo "$rustc_path"
        return 0
    fi

    log_error "rustc executable not found"
    return 1
}

# Get rust version
get_rust_version() {
    local rustc_path="$1"

    if [ -z "$rustc_path" ]; then
        log_error "rustc_path parameter is required"
        return 1
    fi

    local version
    version=$("$rustc_path" --version 2>&1)

    if [ -z "$version" ]; then
        log_error "Could not retrieve Rust version"
        return 1
    fi

    echo "$version"
}

# Run rust smoke test
run_smoke_test() {
    log_info "Running Rust smoke test..."

    local temp_dir
    temp_dir=$(mktemp -d)
    trap "rm -rf '$temp_dir'" EXIT

    local test_file="$temp_dir/test.rs"
    cat > "$test_file" << 'EOF'
fn main() {
    println!("Hello from Rust!");
}
EOF

    if rustc "$test_file" -o "$temp_dir/test" 2>&1 && "$temp_dir/test" 2>&1; then
        log_success "Rust smoke test passed - compilation works"
        return 0
    else
        log_error "Rust smoke test failed"
        return 1
    fi
}

# Display rust info
display_rust_info() {
    log_info "Rust toolchain info:"

    if command -v cargo &> /dev/null; then
        cargo --version 2>&1
    fi

    if command -v rustup &> /dev/null; then
        rustup --version 2>&1
        log_info "Installed toolchains:"
        rustup show 2>&1 | head -n10
    fi
}

# Main entry point
main() {
    log_info "Running Rust verification on macOS..."

    verify_macos
    source_cargo_env

    local rustc_path
    rustc_path=$(find_rustc)

    if [ -z "$rustc_path" ]; then
        log_error "Rust not found - please run install-macos.sh first"
        exit 1
    fi

    local version
    version=$(get_rust_version "$rustc_path")
    log_success "Rust version: ${version}"

    run_smoke_test
    display_rust_info

    log_success "Rust is ready to use!"
    exit 0
}

main "$@"
