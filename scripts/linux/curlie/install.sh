#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting curlie installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install curlie && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/rs/curlie/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -sL "https://github.com/rs/curlie/releases/download/v${version}/curlie_${version}_linux_${arch}.tar.gz" | tar xz -C /usr/local/bin curlie
        chmod +x /usr/local/bin/curlie
        installed=true
    fi

    if command -v curlie &> /dev/null; then
        log_success "curlie installed: $(curlie --version 2>&1 | head -1)"
    else
        log_error "Failed to install curlie"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
