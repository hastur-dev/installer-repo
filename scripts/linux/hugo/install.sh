#!/usr/bin/env bash
# Install script for hugo on Linux (static site generator)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hugo installation on Linux..."

    local installed=false

    # Try snap
    if command -v snap &> /dev/null; then
        snap install hugo --channel=extended && installed=true
    fi

    # Try apt (Debian/Ubuntu)
    if [[ "$installed" == "false" ]] && command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq hugo && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install hugo && installed=true
    fi

    # Try go install
    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        CGO_ENABLED=1 go install -tags extended github.com/gohugoio/hugo@latest && installed=true
    fi

    if command -v hugo &> /dev/null; then
        log_success "hugo installed: $(hugo version 2>&1 | head -1)"
    else
        log_error "Failed to install hugo"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
