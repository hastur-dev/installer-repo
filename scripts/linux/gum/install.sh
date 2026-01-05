#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gum installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install gum && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install github.com/charmbracelet/gum@latest && installed=true
    fi

    if command -v gum &> /dev/null; then
        log_success "gum installed: $(gum --version 2>&1)"
    else
        log_error "Failed to install gum"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
