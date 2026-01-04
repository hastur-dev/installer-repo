#!/usr/bin/env bash
# Install script for nginx on macOS
# Uses Homebrew as the package manager

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-macos.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

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

# Install Homebrew if not present
ensure_homebrew() {
    log_info "Checking for Homebrew..."

    if is_homebrew_installed; then
        log_info "Homebrew is already installed"
        return 0
    fi

    log_info "Installing Homebrew..."

    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})" 2>&1; then
        log_success "Homebrew installed successfully"
    else
        log_error "Failed to install Homebrew"
        return 1
    fi

    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    if ! is_homebrew_installed; then
        log_error "Homebrew installation verification failed"
        return 1
    fi

    return 0
}

# Update Homebrew with retry
update_homebrew() {
    log_info "Updating Homebrew..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew update 2>&1; then
            log_info "Homebrew updated successfully"
            return 0
        fi

        log_info "Update failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to update Homebrew after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Install nginx with retry
install_nginx() {
    log_info "Installing nginx via Homebrew..."

    if brew list nginx &> /dev/null; then
        log_info "nginx is already installed, upgrading..."
        local attempt=0
        while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
            ((attempt++)) || true
            if brew upgrade nginx 2>&1 || true; then
                log_success "nginx upgraded successfully"
                return 0
            fi
            sleep $RETRY_DELAY_SECONDS
        done
        return 0
    fi

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew install nginx 2>&1; then
            log_success "nginx installed successfully"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install nginx after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Start nginx service
start_service() {
    log_info "Starting nginx service..."

    if brew services start nginx 2>&1; then
        log_success "nginx service started"
    else
        log_info "Could not start nginx as a service. Run 'nginx' manually."
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying nginx installation..."

    if ! command -v nginx &> /dev/null; then
        log_error "nginx command not found after installation"
        return 1
    fi

    local nginx_version
    nginx_version=$(nginx -v 2>&1)

    if [ -z "$nginx_version" ]; then
        log_error "Could not retrieve nginx version"
        return 1
    fi

    log_success "nginx verified: ${nginx_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting nginx installation on macOS..."

    verify_macos
    ensure_homebrew
    update_homebrew
    install_nginx
    start_service
    verify_installation

    log_success "Installation complete!"
    log_info "nginx is listening on port 8080 by default (Homebrew)"
    log_info "To manage: brew services [start|stop|restart] nginx"
    exit 0
}

main "$@"
