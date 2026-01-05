#!/usr/bin/env bash
# Install script for croc on Linux (secure file transfer)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting croc installation on Linux..."

    local installed=false

    # Try snap (Ubuntu/Debian)
    if command -v snap &> /dev/null; then
        snap install croc && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install croc && installed=true
    fi

    # Download from GitHub releases as fallback
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/schollz/croc/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="64bit" ;;
                aarch64) arch="ARM64" ;;
                armv7l) arch="ARM" ;;
            esac
            curl -sL "https://github.com/schollz/croc/releases/download/v${version}/croc_v${version}_Linux-${arch}.tar.gz" | tar xz -C /usr/local/bin croc
            chmod +x /usr/local/bin/croc
            installed=true
        fi
    fi

    if command -v croc &> /dev/null; then
        log_success "croc installed: $(croc --version 2>&1)"
    else
        log_error "Failed to install croc"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
