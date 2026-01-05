#!/usr/bin/env bash
# Install script for helm on Linux (Kubernetes package manager)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting helm installation on Linux..."

    local installed=false

    # Try snap
    if command -v snap &> /dev/null; then
        snap install helm --classic && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install helm && installed=true
    fi

    # Official install script
    if [[ "$installed" == "false" ]]; then
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        installed=true
    fi

    if command -v helm &> /dev/null; then
        log_success "helm installed: $(helm version --short 2>&1)"
    else
        log_error "Failed to install helm"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
