#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting miniserve installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install miniserve && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/svenstaro/miniserve/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="aarch64" ;;
        esac
        curl -sL "https://github.com/svenstaro/miniserve/releases/download/v${version}/miniserve-${version}-${arch}-unknown-linux-gnu" -o /usr/local/bin/miniserve
        chmod +x /usr/local/bin/miniserve
        installed=true
    fi

    if command -v miniserve &> /dev/null; then
        log_success "miniserve installed: $(miniserve --version 2>&1)"
    else
        log_error "Failed to install miniserve"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
