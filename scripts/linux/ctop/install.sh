#!/usr/bin/env bash
# Install script for ctop on Linux (container metrics)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting ctop installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install ctop && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/bcicen/ctop/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="amd64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/bcicen/ctop/releases/download/v${version}/ctop-${version}-linux-${arch}" -o /usr/local/bin/ctop
            chmod +x /usr/local/bin/ctop
            installed=true
        fi
    fi

    if command -v ctop &> /dev/null; then
        log_success "ctop installed: $(ctop -v 2>&1)"
    else
        log_error "Failed to install ctop"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
