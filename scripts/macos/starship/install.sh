#!/usr/bin/env bash
# Install script for Starship prompt on macOS

set -euo pipefail

readonly SCRIPT_NAME="install-macos.sh"
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

install_starship() {
    log_info "Installing Starship via Homebrew..."
    if brew list starship &> /dev/null; then
        brew upgrade starship 2>&1 || true
        log_success "Starship upgraded"
        return 0
    fi
    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        if brew install starship 2>&1; then
            log_success "Starship installed successfully"
            return 0
        fi
        sleep $RETRY_DELAY_SECONDS
    done
    return 1
}

verify_installation() {
    log_info "Verifying Starship installation..."
    if ! command -v starship &> /dev/null; then
        log_error "starship command not found"
        return 1
    fi
    local version
    version=$(starship --version 2>&1 | head -n 1)
    log_success "Starship verified: ${version}"
    log_info "Add to your shell config: eval \"\$(starship init zsh)\""
    return 0
}

main() {
    log_info "Starting Starship installation on macOS..."
    ensure_homebrew
    brew update
    install_starship
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
