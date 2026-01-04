#!/usr/bin/env bash
# Install script for Starship prompt on Linux

set -euo pipefail

readonly SCRIPT_NAME="install-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

install_starship() {
    log_info "Installing Starship..."
    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        if curl -sS https://starship.rs/install.sh | sh -s -- -y 2>&1; then
            log_success "Starship installed successfully"
            return 0
        fi
        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done
    log_error "Failed to install Starship after ${MAX_RETRY_ATTEMPTS} attempts"
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
    log_info "Add to your shell config: eval \"\$(starship init bash)\" or eval \"\$(starship init zsh)\""
    return 0
}

main() {
    log_info "Starting Starship installation on Linux..."
    install_starship
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
