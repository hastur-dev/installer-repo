#!/usr/bin/env bash
# Uninstall script for Rust on Linux
# Uses rustup for uninstallation

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2

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

# Source cargo environment
source_cargo_env() {
    if [ -f "$HOME/.cargo/env" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.cargo/env"
    fi
}

# Check if Rust is installed
is_rust_installed() {
    source_cargo_env
    if command -v rustc &> /dev/null || command -v rustup &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall Rust using rustup
uninstall_rust() {
    log_info "Uninstalling Rust via rustup..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if rustup self uninstall -y 2>&1; then
            log_success "Rust uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall Rust after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying Rust uninstallation..."

    # Clear cached command locations
    hash -r 2>/dev/null || true

    if command -v rustc &> /dev/null; then
        log_error "rustc is still installed"
        return 1
    fi

    if [ -d "$HOME/.cargo" ]; then
        log_info "Note: ~/.cargo directory still exists, you may want to remove it manually"
    fi

    if [ -d "$HOME/.rustup" ]; then
        log_info "Note: ~/.rustup directory still exists, you may want to remove it manually"
    fi

    log_success "Rust has been removed from the system"
    return 0
}

# Main entry point
main() {
    log_info "Starting Rust uninstallation on Linux..."

    source_cargo_env

    if ! is_rust_installed; then
        log_info "Rust is not installed, nothing to uninstall"
        exit 0
    fi

    uninstall_rust
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
