#!/usr/bin/env bash
# Install script for Rust on macOS
# Uses rustup for installation

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-macos.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly RUSTUP_INIT_URL="https://sh.rustup.rs"

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

# Check if curl is available
check_curl() {
    log_info "Checking for curl..."

    if command -v curl &> /dev/null; then
        log_info "curl is available"
        return 0
    fi

    log_error "curl is required but not installed"
    return 1
}

# Install Rust using rustup
install_rust() {
    log_info "Installing Rust via rustup..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if curl --proto '=https' --tlsv1.2 -sSf ${RUSTUP_INIT_URL} | sh -s -- -y 2>&1; then
            log_success "Rust installed successfully"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install Rust after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Source cargo environment
source_cargo_env() {
    log_info "Sourcing Cargo environment..."

    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
        log_info "Cargo environment sourced"
        return 0
    fi

    log_error "Cargo environment file not found"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying Rust installation..."

    if ! command -v rustc &> /dev/null; then
        log_error "rustc command not found after installation"
        return 1
    fi

    local rustc_version
    rustc_version=$(rustc --version 2>&1)

    if [ -z "$rustc_version" ]; then
        log_error "Could not retrieve Rust version"
        return 1
    fi

    log_success "Rust verified: ${rustc_version}"

    if command -v cargo &> /dev/null; then
        local cargo_version
        cargo_version=$(cargo --version 2>&1)
        log_success "Cargo verified: ${cargo_version}"
    fi

    if command -v rustup &> /dev/null; then
        local rustup_version
        rustup_version=$(rustup --version 2>&1)
        log_success "rustup verified: ${rustup_version}"
    fi

    return 0
}

# Main entry point
main() {
    log_info "Starting Rust installation on macOS..."

    verify_macos
    check_curl

    # Check if already installed
    if command -v rustc &> /dev/null; then
        log_info "Rust is already installed, updating..."
        if command -v rustup &> /dev/null; then
            rustup update 2>&1 || true
        fi
    else
        install_rust
    fi

    source_cargo_env
    verify_installation

    log_success "Installation complete!"
    log_info "Note: You may need to restart your shell or run 'source ~/.cargo/env'"
    exit 0
}

main "$@"
