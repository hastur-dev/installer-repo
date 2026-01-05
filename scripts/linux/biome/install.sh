#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting biome installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install biome && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v npm &> /dev/null; then
        npm install -g @biomejs/biome && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v cargo &> /dev/null; then
        cargo install --locked biome_cli && installed=true
    fi

    if command -v biome &> /dev/null; then
        log_success "biome installed: $(biome --version 2>&1)"
    else
        log_error "Failed to install biome"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
