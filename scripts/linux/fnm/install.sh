#!/usr/bin/env bash
# Install script for fnm on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting fnm installation on Linux..."

    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm fnm 2>&1 || true
    fi

    if ! command -v fnm &> /dev/null && command -v cargo &> /dev/null; then
        cargo install fnm --locked 2>&1
    fi

    if ! command -v fnm &> /dev/null; then
        # Try official installer
        curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell 2>&1
    fi

    if ! command -v fnm &> /dev/null; then
        log_error "fnm command not found"
        exit 1
    fi
    log_success "fnm verified: $(fnm --version)"
    log_info "Add to shell config: eval \"\$(fnm env)\""
    log_success "Installation complete!"
    exit 0
}

main "$@"
