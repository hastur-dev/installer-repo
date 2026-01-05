#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting bun installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install oven-sh/bun/bun && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        curl -fsSL https://bun.sh/install | bash
        installed=true
    fi

    export PATH="$HOME/.bun/bin:$PATH"
    if command -v bun &> /dev/null; then
        log_success "bun installed: $(bun --version 2>&1)"
    else
        log_error "Failed to install bun"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
