#!/usr/bin/env bash
# Uninstall script for Emacs on macOS
# Uses Homebrew as the package manager

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-macos.sh"
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

# Check if Homebrew is installed
is_homebrew_installed() {
    if command -v brew &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if Emacs is installed
is_emacs_installed() {
    if command -v emacs &> /dev/null; then
        return 0
    fi
    if brew list emacs &> /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Uninstall Emacs with retry
uninstall_emacs() {
    log_info "Uninstalling Emacs via Homebrew..."

    if ! brew list emacs &> /dev/null 2>&1; then
        log_info "Emacs is not installed via Homebrew"
        return 0
    fi

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew uninstall emacs 2>&1; then
            log_success "Emacs uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall Emacs after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Clean up configuration files (optional)
cleanup_config() {
    log_info "Cleaning up Emacs configuration files..."

    local config_files=(
        "$HOME/.emacs"
        "$HOME/.emacs.d"
    )

    local iteration=0
    for config in "${config_files[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt 20 ]; then
            log_error "Exceeded iteration limit"
            break
        fi

        if [ -e "$config" ]; then
            log_info "Removing: ${config}"
            rm -rf "$config" 2>/dev/null || true
        fi
    done

    log_info "Configuration cleanup complete"
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying Emacs uninstallation..."

    if brew list emacs &> /dev/null 2>&1; then
        log_error "Emacs is still installed via Homebrew"
        return 1
    fi

    log_success "Emacs has been removed from the system"
    return 0
}

# Main entry point
main() {
    log_info "Starting Emacs uninstallation on macOS..."

    verify_macos

    if ! is_homebrew_installed; then
        log_error "Homebrew is not installed"
        exit 1
    fi

    if ! is_emacs_installed; then
        log_info "Emacs is not installed, nothing to uninstall"
        exit 0
    fi

    uninstall_emacs
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
