#!/usr/bin/env bash
# Uninstall script for Vim on macOS
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

# Check if Vim is installed via Homebrew
is_vim_installed_via_brew() {
    if brew list vim &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if Vim command exists
is_vim_installed() {
    if command -v vim &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall Vim with retry
uninstall_vim() {
    log_info "Uninstalling Vim via Homebrew..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew uninstall vim 2>&1; then
            log_success "Vim uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall Vim after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Clean up configuration files (optional)
cleanup_config() {
    log_info "Cleaning up Vim configuration files..."

    local config_files=(
        "$HOME/.vimrc"
        "$HOME/.vim"
        "$HOME/.viminfo"
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
    log_info "Verifying Vim uninstallation..."

    # Check Homebrew package
    if is_vim_installed_via_brew; then
        log_error "Vim is still installed via Homebrew"
        return 1
    fi

    log_success "Vim has been removed via Homebrew"

    # Note: System vim may still exist at /usr/bin/vim
    if [ -x "/usr/bin/vim" ]; then
        log_info "Note: System vim at /usr/bin/vim still exists (this is expected)"
    fi

    return 0
}

# Main entry point
main() {
    log_info "Starting Vim uninstallation on macOS..."

    # Verify macOS
    verify_macos

    # Check if Homebrew is available
    if ! is_homebrew_installed; then
        log_error "Homebrew is not installed"
        exit 1
    fi

    # Check if Vim was installed via Homebrew
    if ! is_vim_installed_via_brew; then
        log_info "Vim is not installed via Homebrew, nothing to uninstall"

        if is_vim_installed; then
            log_info "Note: Vim exists but was not installed via Homebrew"
        fi

        exit 0
    fi

    # Uninstall Vim
    uninstall_vim

    # Optional: Clean up config files
    # Uncomment the next line to remove config files
    # cleanup_config

    # Verify
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
