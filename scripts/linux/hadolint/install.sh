#!/usr/bin/env bash
# Install script for hadolint on Linux (Dockerfile linter)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting hadolint installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install hadolint && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -sL "https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-${arch}" -o /usr/local/bin/hadolint
        chmod +x /usr/local/bin/hadolint
        installed=true
    fi

    if command -v hadolint &> /dev/null; then
        log_success "hadolint installed: $(hadolint --version 2>&1)"
    else
        log_error "Failed to install hadolint"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
