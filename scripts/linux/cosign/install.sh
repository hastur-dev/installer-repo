#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting cosign installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install cosign && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v go &> /dev/null; then
        go install github.com/sigstore/cosign/v2/cmd/cosign@latest && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local arch=$(uname -m)
        case "$arch" in
            x86_64) arch="amd64" ;;
            aarch64) arch="arm64" ;;
        esac
        curl -sL "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-${arch}" -o /usr/local/bin/cosign
        chmod +x /usr/local/bin/cosign
        installed=true
    fi

    if command -v cosign &> /dev/null; then
        log_success "cosign installed: $(cosign version 2>&1 | head -1)"
    else
        log_error "Failed to install cosign"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
