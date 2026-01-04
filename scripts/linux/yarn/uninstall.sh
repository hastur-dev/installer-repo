#!/usr/bin/env bash
# Uninstall script for Yarn on Linux

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

log_warn() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_warn: message cannot be empty" >&2
        return 1
    fi
    echo "[WARN] ${SCRIPT_NAME}: ${message}"
}

# Check if Yarn is installed
is_yarn_installed() {
    if command -v yarn &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if npm is installed
is_npm_installed() {
    if command -v npm &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if corepack is available
is_corepack_available() {
    if command -v corepack &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall Yarn via npm
uninstall_yarn_via_npm() {
    log_info "Uninstalling Yarn via npm..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if npm uninstall -g yarn 2>&1; then
            log_success "Yarn uninstalled successfully via npm"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    return 1
}

# Disable Yarn via corepack
disable_yarn_via_corepack() {
    log_info "Disabling Yarn via corepack..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if corepack disable yarn 2>&1 || true; then
            log_success "Yarn disabled via corepack"
            return 0
        fi

        log_info "Disable failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying Yarn uninstallation..."

    # Refresh PATH
    hash -r 2>/dev/null || true

    if is_yarn_installed; then
        log_warn "Yarn is still available in PATH"
        return 1
    fi

    log_success "Yarn has been removed"
    return 0
}

# Main entry point
main() {
    log_info "Starting Yarn uninstallation on Linux..."

    if ! is_yarn_installed; then
        log_info "Yarn is not installed, nothing to uninstall"
        exit 0
    fi

    local yarn_version
    yarn_version=$(yarn --version 2>&1)
    log_info "Current Yarn installation: ${yarn_version}"

    local uninstalled=false

    # Try corepack disable first
    if is_corepack_available; then
        disable_yarn_via_corepack || true
    fi

    # Try npm uninstall
    if is_npm_installed; then
        if uninstall_yarn_via_npm; then
            uninstalled=true
        fi
    fi

    if ! $uninstalled; then
        log_warn "Could not uninstall Yarn via package manager"
        log_info "You may need to manually remove Yarn"
    fi

    verify_uninstall || true

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
