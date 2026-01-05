#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vhs installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install vhs && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/charmbracelet/vhs/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="arm64" ;;
        esac
        mkdir -p /tmp/vhs-install
        curl -sL "https://github.com/charmbracelet/vhs/releases/download/v${version}/vhs_${version}_Linux_${arch}.tar.gz" | tar xz -C /tmp/vhs-install
        mv /tmp/vhs-install/vhs /usr/local/bin/
        rm -rf /tmp/vhs-install
        chmod +x /usr/local/bin/vhs
        installed=true
    fi

    if command -v vhs &> /dev/null; then
        log_success "vhs installed: $(vhs --version 2>&1)"
    else
        log_error "Failed to install vhs"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
