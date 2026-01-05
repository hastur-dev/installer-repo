#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting kustomize installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install kustomize && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v snap &> /dev/null; then
        snap install kustomize && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
        mv kustomize /usr/local/bin/
        installed=true
    fi

    if command -v kustomize &> /dev/null; then
        log_success "kustomize installed: $(kustomize version 2>&1)"
    else
        log_error "Failed to install kustomize"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
