#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting skaffold installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install skaffold && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -Lo /usr/local/bin/skaffold "https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-${arch}"
        chmod +x /usr/local/bin/skaffold
        installed=true
    fi

    if command -v skaffold &> /dev/null; then
        log_success "skaffold installed: $(skaffold version 2>&1)"
    else
        log_error "Failed to install skaffold"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
