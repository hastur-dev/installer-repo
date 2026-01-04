#!/usr/bin/env bash
# Install script for glow on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting glow installation on Linux..."

    if command -v apt-get &> /dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg 2>/dev/null || true
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list > /dev/null
        sudo apt-get update -y && sudo apt-get install -y glow 2>&1 || true
    fi
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm glow 2>&1 || true
    fi

    if ! command -v glow &> /dev/null; then
        log_error "glow command not found"
        exit 1
    fi
    log_success "glow verified: $(glow --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
