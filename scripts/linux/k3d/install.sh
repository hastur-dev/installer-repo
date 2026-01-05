#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting k3d installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install k3d && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
        installed=true
    fi

    if command -v k3d &> /dev/null; then
        log_success "k3d installed: $(k3d version 2>&1 | head -1)"
    else
        log_error "Failed to install k3d"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
