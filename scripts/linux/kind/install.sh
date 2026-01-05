#!/usr/bin/env bash
# Install script for kind on Linux (Kubernetes in Docker)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting kind installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install kind && installed=true
    fi

    # Try go install
    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install sigs.k8s.io/kind@latest && installed=true
    fi

    # Download binary
    if [[ "$installed" == "false" ]]; then
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -Lo /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-${arch}"
        chmod +x /usr/local/bin/kind
        installed=true
    fi

    if command -v kind &> /dev/null; then
        log_success "kind installed: $(kind version 2>&1)"
    else
        log_error "Failed to install kind"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
