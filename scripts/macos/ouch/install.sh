#!/usr/bin/env bash
# Install script for ouch on macOS

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
    log_info "Starting ouch installation on macOS..."
    ensure_homebrew
    brew update
    if brew list ouch &> /dev/null; then brew upgrade ouch 2>&1 || true; else brew install ouch; fi
    log_success "ouch verified: $(ouch --version)"
    log_success "Installation complete!"
    exit 0
}

main "$@"
