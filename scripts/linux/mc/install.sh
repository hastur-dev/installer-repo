#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mc (MinIO client) installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install minio/stable/mc && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -sL "https://dl.min.io/client/mc/release/linux-${arch}/mc" -o /usr/local/bin/mc
        chmod +x /usr/local/bin/mc
        installed=true
    fi

    if command -v mc &> /dev/null; then
        log_success "mc installed: $(mc --version 2>&1 | head -1)"
    else
        log_error "Failed to install mc"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
