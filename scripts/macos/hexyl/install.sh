#!/usr/bin/env bash
# Install script for hexyl on macOS

set -euo pipefail

readonly SCRIPT_NAME="install.sh"
readonly HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

ensure_homebrew() {
    if command -v brew &> /dev/null; then return 0; fi
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL ${HOMEBREW_INSTALL_URL})"
    [ -f "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"
}

main() {
    log_info "Starting hexyl installation on macOS..."
    ensure_homebrew
    brew update
    if brew list hexyl &> /dev/null; then brew upgrade hexyl 2>&1 || true; else brew install hexyl; fi
    log_success "hexyl verified: $(hexyl --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
