#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting poetry installation on Linux..."
    local installed=false

    export POETRY_HOME="/usr/local"
    curl -sSL https://install.python-poetry.org | python3 -
    installed=true

    if command -v poetry &> /dev/null; then
        log_success "poetry installed: $(poetry --version 2>&1)"
    else
        log_error "Failed to install poetry"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
