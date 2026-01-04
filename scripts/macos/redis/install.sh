#!/usr/bin/env bash
# Install script for Redis on macOS
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

# Install Redis with retry
install_redis() {
    log_info "Installing Redis via Homebrew..."

    if brew list redis &> /dev/null; then
        log_info "Redis is already installed, upgrading..."
        local attempt=0
        while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
            ((attempt++)) || true
            if brew upgrade redis 2>&1 || true; then
                log_success "Redis upgraded successfully"
                return 0
            fi
            sleep $RETRY_DELAY_SECONDS
        done
        return 0
    fi

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew install redis 2>&1; then
            log_success "Redis installed successfully"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install Redis after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Start Redis service
start_service() {
    log_info "Starting Redis service..."

    if brew services start redis 2>&1; then
        log_success "Redis service started"
    else
        log_info "Could not start Redis as a service. Run 'redis-server' manually."
    fi
}

# Verify installation
verify_installation() {
    log_info "Verifying Redis installation..."

    if ! command -v redis-server &> /dev/null; then
        log_error "redis-server command not found after installation"
        return 1
    fi

    local redis_version
    redis_version=$(redis-server --version 2>&1)

    if [ -z "$redis_version" ]; then
        log_error "Could not retrieve Redis version"
        return 1
    fi

    log_success "Redis verified: ${redis_version}"

    if command -v redis-cli &> /dev/null; then
        log_success "redis-cli is also available"
    fi

    return 0
}

# Main entry point
main() {
    log_info "Starting Redis installation on macOS..."

    verify_macos
    ensure_homebrew
    update_homebrew
    install_redis
    start_service
    verify_installation

    log_success "Installation complete!"
    log_info "Redis is listening on localhost:6379 by default"
    log_info "To manage: brew services [start|stop|restart] redis"
    exit 0
}

main "$@"
