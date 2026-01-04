#!/usr/bin/env bash
# Install script for hyperfine on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

install_hyperfine() {
    log_info "Installing hyperfine..."
    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        if command -v apt-get &> /dev/null; then
            if sudo apt-get update -y && sudo apt-get install -y hyperfine 2>&1; then
                log_success "hyperfine installed via apt"
                return 0
            fi
        elif command -v dnf &> /dev/null; then
            if sudo dnf install -y hyperfine 2>&1; then
                log_success "hyperfine installed via dnf"
                return 0
            fi
        elif command -v pacman &> /dev/null; then
            if sudo pacman -S --noconfirm hyperfine 2>&1; then
                log_success "hyperfine installed via pacman"
                return 0
            fi
        elif command -v cargo &> /dev/null; then
            if cargo install hyperfine --locked 2>&1; then
                log_success "hyperfine installed via cargo"
                return 0
            fi
        fi
        sleep $RETRY_DELAY_SECONDS
    done
    return 1
}

verify_installation() {
    if ! command -v hyperfine &> /dev/null; then
        log_error "hyperfine command not found"
        return 1
    fi
    log_success "hyperfine verified: $(hyperfine --version)"
    return 0
}

main() {
    log_info "Starting hyperfine installation on Linux..."
    install_hyperfine
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
