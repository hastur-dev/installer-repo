#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting taplo installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install taplo && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v cargo &> /dev/null; then
        cargo install taplo-cli --locked && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v npm &> /dev/null; then
        npm install -g @taplo/cli && installed=true
    fi

    if command -v taplo &> /dev/null; then
        log_success "taplo installed: $(taplo --version 2>&1)"
    else
        log_error "Failed to install taplo"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
