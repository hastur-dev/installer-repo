#!/usr/bin/env bash
# Install script for Rust toolchain (cargo) on macOS
# Uses rustup for installation

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-macos.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly RUSTUP_INSTALL_URL="https://sh.rustup.rs"

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

# Check if cargo is already installed
is_cargo_installed() {
    if command -v cargo &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if rustup is installed
is_rustup_installed() {
    if command -v rustup &> /dev/null; then
        return 0
    fi
    return 1
}

# Install Rust via rustup
install_rust() {
    log_info "Installing Rust toolchain via rustup..."

    if is_rustup_installed; then
        log_info "rustup is already installed, updating..."
        local attempt=0
        while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
            ((attempt++)) || true
            if rustup update 2>&1; then
                log_success "Rust toolchain updated successfully"
                return 0
            fi
            log_info "Update failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
            sleep $RETRY_DELAY_SECONDS
        done
        log_error "Failed to update Rust toolchain"
        return 1
    fi

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if curl --proto '=https' --tlsv1.2 -sSf ${RUSTUP_INSTALL_URL} | sh -s -- -y 2>&1; then
            log_success "Rust toolchain installed successfully"
            # Source cargo environment
            if [ -f "$HOME/.cargo/env" ]; then
                source "$HOME/.cargo/env"
            fi
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install Rust toolchain after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying Rust installation..."

    # Source cargo environment if not already in PATH
    if [ -f "$HOME/.cargo/env" ]; then
        source "$HOME/.cargo/env"
    fi

    if ! command -v cargo &> /dev/null; then
        log_error "cargo command not found after installation"
        return 1
    fi

    local cargo_version
    cargo_version=$(cargo --version 2>&1)

    if [ -z "$cargo_version" ]; then
        log_error "Could not retrieve cargo version"
        return 1
    fi

    log_success "cargo verified: ${cargo_version}"

    if command -v rustc &> /dev/null; then
        local rustc_version
        rustc_version=$(rustc --version 2>&1)
        log_success "rustc verified: ${rustc_version}"
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
    log_info "Starting Rust toolchain installation on macOS..."

    verify_macos
    install_rust
    verify_installation

    log_success "Installation complete!"
    log_info "Please restart your shell or run: source \$HOME/.cargo/env"
    exit 0
}

main "$@"
