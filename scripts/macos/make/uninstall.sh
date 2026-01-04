#!/usr/bin/env bash
# Uninstall script for Make on macOS
# Removes GNU Make installed via Homebrew (system make from Xcode CLT is preserved)

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

# Check if GNU Make is installed via Homebrew
is_make_installed_via_brew() {
    if brew list make &> /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Uninstall GNU Make with retry
uninstall_make() {
    log_info "Uninstalling GNU Make via Homebrew..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew uninstall make 2>&1; then
            log_success "GNU Make uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall GNU Make after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying GNU Make uninstallation..."

    if is_make_installed_via_brew; then
        log_error "GNU Make is still installed via Homebrew"
        return 1
    fi

    log_success "GNU Make has been removed from Homebrew"
    log_info "Note: System make from Xcode Command Line Tools is still available"
    return 0
}

# Main entry point
main() {
    log_info "Starting GNU Make uninstallation on macOS..."

    verify_macos

    if ! is_homebrew_installed; then
        log_info "Homebrew is not installed, nothing to uninstall"
        exit 0
    fi

    if ! is_make_installed_via_brew; then
        log_info "GNU Make is not installed via Homebrew, nothing to uninstall"
        log_info "System make from Xcode CLT may still be available"
        exit 0
    fi

    if command -v gmake &> /dev/null; then
        local gmake_version
        gmake_version=$(gmake --version 2>&1 | head -n 1)
        log_info "Current GNU Make installation: ${gmake_version}"
    fi

    uninstall_make
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
