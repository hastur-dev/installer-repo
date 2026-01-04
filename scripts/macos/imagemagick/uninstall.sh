#!/usr/bin/env bash
# Uninstall script for ImageMagick on macOS
# Removes ImageMagick installed via Homebrew

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

log_warn() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_warn: message cannot be empty" >&2
        return 1
    fi
    echo "[WARN] ${SCRIPT_NAME}: ${message}"
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

# Check if ImageMagick is installed via Homebrew
is_imagemagick_installed_via_brew() {
    if brew list imagemagick &> /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Uninstall ImageMagick with retry
uninstall_imagemagick() {
    log_info "Uninstalling ImageMagick via Homebrew..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew uninstall imagemagick 2>&1; then
            log_success "ImageMagick uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall ImageMagick after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying ImageMagick uninstallation..."

    if is_imagemagick_installed_via_brew; then
        log_error "ImageMagick is still installed via Homebrew"
        return 1
    fi

    log_success "Homebrew ImageMagick has been removed"
    return 0
}

# Main entry point
main() {
    log_info "Starting ImageMagick uninstallation on macOS..."

    verify_macos

    if ! is_homebrew_installed; then
        log_error "Homebrew is not installed"
        exit 1
    fi

    if ! is_imagemagick_installed_via_brew; then
        log_info "ImageMagick is not installed via Homebrew, nothing to uninstall"
        exit 0
    fi

    uninstall_imagemagick
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
