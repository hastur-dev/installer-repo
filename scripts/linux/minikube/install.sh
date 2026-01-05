#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting minikube installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install minikube && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${arch}"
        install minikube-linux-${arch} /usr/local/bin/minikube
        rm minikube-linux-${arch}
        installed=true
    fi

    if command -v minikube &> /dev/null; then
        log_success "minikube installed: $(minikube version --short 2>&1)"
    else
        log_error "Failed to install minikube"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
