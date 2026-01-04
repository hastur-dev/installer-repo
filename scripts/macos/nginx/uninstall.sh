#!/usr/bin/env bash
# Uninstall script for nginx on macOS
# Removes nginx installed via Homebrew

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

# Check if nginx is installed via Homebrew
is_nginx_installed_via_brew() {
    if brew list nginx &> /dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Stop nginx service
stop_service() {
    log_info "Stopping nginx service..."
    brew services stop nginx 2>/dev/null || true
    log_info "nginx service stopped"
}

# Uninstall nginx with retry
uninstall_nginx() {
    log_info "Uninstalling nginx via Homebrew..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew uninstall nginx 2>&1; then
            log_success "nginx uninstalled successfully"
            return 0
        fi

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall nginx after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying nginx uninstallation..."

    if is_nginx_installed_via_brew; then
        log_error "nginx is still installed via Homebrew"
        return 1
    fi

    log_success "nginx has been removed"
    return 0
}

# Main entry point
main() {
    log_info "Starting nginx uninstallation on macOS..."

    verify_macos

    if ! is_homebrew_installed; then
        log_error "Homebrew is not installed"
        exit 1
    fi

    if ! is_nginx_installed_via_brew; then
        log_info "nginx is not installed via Homebrew, nothing to uninstall"
        exit 0
    fi

    if command -v nginx &> /dev/null; then
        local nginx_version
        nginx_version=$(nginx -v 2>&1)
        log_info "Current nginx installation: ${nginx_version}"
    fi

    stop_service
    uninstall_nginx
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
