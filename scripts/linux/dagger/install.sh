#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting dagger installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install dagger/tap/dagger && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        curl -L https://dl.dagger.io/dagger/install.sh | sh
        mv ./bin/dagger /usr/local/bin/
        rmdir ./bin 2>/dev/null || true
        installed=true
    fi

    if command -v dagger &> /dev/null; then
        log_success "dagger installed: $(dagger version 2>&1)"
    else
        log_error "Failed to install dagger"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
