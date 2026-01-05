#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting uv installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install uv && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="aarch64" ;;
        esac
        curl -sL "https://github.com/astral-sh/uv/releases/latest/download/uv-${arch}-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
        mv /tmp/uv-${arch}-unknown-linux-gnu/uv /usr/local/bin/
        mv /tmp/uv-${arch}-unknown-linux-gnu/uvx /usr/local/bin/
        chmod +x /usr/local/bin/uv /usr/local/bin/uvx
        installed=true
    fi

    if command -v uv &> /dev/null; then
        log_success "uv installed: $(uv --version 2>&1)"
    else
        log_error "Failed to install uv"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
