#!/usr/bin/env bash
# Install script for Make on macOS
# Uses Xcode Command Line Tools or Homebrew

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

# Check if Xcode Command Line Tools are installed
is_xcode_cli_installed() {
    if xcode-select -p &> /dev/null; then
        return 0
    fi
    return 1
}

# Install Xcode Command Line Tools
install_xcode_cli() {
    log_info "Installing Xcode Command Line Tools..."

    if is_xcode_cli_installed; then
        log_info "Xcode Command Line Tools already installed"
        return 0
    fi

    xcode-select --install 2>&1 || true
    log_info "Xcode Command Line Tools installation initiated"
    log_info "Please complete the installation in the popup dialog"
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

    return 0
}

# Install GNU Make with retry (newer version than system make)
install_make() {
    log_info "Installing GNU Make via Homebrew..."

    if ! is_homebrew_installed; then
        log_info "Make is available via Xcode Command Line Tools"
        install_xcode_cli
        return 0
    fi

    if brew list make &> /dev/null; then
        log_info "GNU Make is already installed, upgrading..."
        local attempt=0
        while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
            ((attempt++)) || true
            if brew upgrade make 2>&1 || true; then
                log_success "GNU Make upgraded successfully"
                return 0
            fi
            sleep $RETRY_DELAY_SECONDS
        done
        return 0
    fi

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if brew install make 2>&1; then
            log_success "GNU Make installed successfully"
            log_info "Note: GNU make is installed as 'gmake'. Add $(brew --prefix)/opt/make/libexec/gnubin to PATH to use as 'make'"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install GNU Make after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying Make installation..."

    if ! command -v make &> /dev/null; then
        log_error "make command not found after installation"
        return 1
    fi

    local make_version
    make_version=$(make --version 2>&1 | head -n 1)

    if [ -z "$make_version" ]; then
        log_error "Could not retrieve Make version"
        return 1
    fi

    log_success "Make verified: ${make_version}"

    if command -v gmake &> /dev/null; then
        local gmake_version
        gmake_version=$(gmake --version 2>&1 | head -n 1)
        log_success "GNU Make also available: ${gmake_version}"
    fi

    return 0
}

# Main entry point
main() {
    log_info "Starting Make installation on macOS..."

    verify_macos
    ensure_homebrew
    install_make
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
