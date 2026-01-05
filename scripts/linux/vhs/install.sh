#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vhs installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install vhs && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install github.com/charmbracelet/vhs@latest && installed=true
    fi

    if command -v vhs &> /dev/null; then
        log_success "vhs installed: $(vhs --version 2>&1)"
    else
        log_error "Failed to install vhs"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
