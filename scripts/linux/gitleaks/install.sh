#!/usr/bin/env bash
# Install script for gitleaks on Linux (secret scanner)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting gitleaks installation on Linux..."

    local installed=false

    # Try brew
    if command -v brew &> /dev/null; then
        brew install gitleaks && installed=true
    fi

    # Download from GitHub releases
    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        if [[ -n "$version" ]]; then
            local arch
            arch=$(uname -m)
            case "$arch" in
                x86_64) arch="x64" ;;
                aarch64) arch="arm64" ;;
            esac
            curl -sL "https://github.com/gitleaks/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_${arch}.tar.gz" | tar xz -C /usr/local/bin gitleaks
            chmod +x /usr/local/bin/gitleaks
            installed=true
        fi
    fi

    if command -v gitleaks &> /dev/null; then
        log_success "gitleaks installed: $(gitleaks version 2>&1)"
    else
        log_error "Failed to install gitleaks"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
