#!/usr/bin/env bash
# Install script for k9s on Linux (Kubernetes CLI dashboard)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting k9s installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install derailed/k9s/k9s && installed=true
    fi

    # Try snap
    if [[ "$installed" == "false" ]] && command -v snap &> /dev/null; then
        snap install k9s && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/derailed/k9s/releases/download/v${version}/k9s_Linux_${arch}.tar.gz" | tar xz -C /usr/local/bin k9s
            chmod +x /usr/local/bin/k9s
            installed=true
        fi
    fi

    if command -v k9s &> /dev/null; then
        log_success "k9s installed: $(k9s version --short 2>&1 | head -1)"
    else
        log_error "Failed to install k9s"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
