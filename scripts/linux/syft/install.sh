#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting syft installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install syft && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
        installed=true
    fi

    if command -v syft &> /dev/null; then
        log_success "syft installed: $(syft version 2>&1 | head -1)"
    else
        log_error "Failed to install syft"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
