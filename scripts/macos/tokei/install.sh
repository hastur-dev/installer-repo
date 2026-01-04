#!/usr/bin/env bash
# Install script for tokei on macOS

set -euo pipefail

readonly SCRIPT_NAME="install.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

ensure_homebrew() {
    if command -v brew &> /dev/null; then
        log_info "Homebrew is already installed"
        return 0
    fi
    log_info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})"
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

install_tokei() {
    log_info "Installing tokei via Homebrew..."
    if brew list tokei &> /dev/null; then
        brew upgrade tokei 2>&1 || true
        log_success "tokei upgraded"
        return 0
    fi
    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        if brew install tokei 2>&1; then
            log_success "tokei installed successfully"
            return 0
        fi
        sleep $RETRY_DELAY_SECONDS
    done
    return 1
}

verify_installation() {
    log_info "Verifying tokei installation..."
    if ! command -v tokei &> /dev/null; then
        log_error "tokei command not found"
        return 1
    fi
    local version
    version=$(tokei --version 2>&1)
    log_success "tokei verified: ${version}"
    return 0
}

main() {
    log_info "Starting tokei installation on macOS..."
    ensure_homebrew
    brew update
    install_tokei
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
