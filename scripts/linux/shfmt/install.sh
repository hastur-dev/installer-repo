#!/usr/bin/env bash
# Install script for shfmt on Linux (shell formatter)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting shfmt installation on Linux..."

    local installed=false

    # Try snap
    if command -v snap &> /dev/null; then
        snap install shfmt && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install shfmt && installed=true
    fi

    # Try go install
    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install mvdan.cc/sh/v3/cmd/shfmt@latest && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/mvdan/sh/releases/download/v${version}/shfmt_v${version}_linux_${arch}" -o /usr/local/bin/shfmt
            chmod +x /usr/local/bin/shfmt
            installed=true
        fi
    fi

    if command -v shfmt &> /dev/null; then
        log_success "shfmt installed: $(shfmt --version 2>&1)"
    else
        log_error "Failed to install shfmt"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
