#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting git-cliff installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install git-cliff && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/orhun/git-cliff/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="aarch64" ;;
        esac
        curl -sL "https://github.com/orhun/git-cliff/releases/download/v${version}/git-cliff-${version}-${arch}-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
        mv /tmp/git-cliff-${version}/git-cliff /usr/local/bin/
        chmod +x /usr/local/bin/git-cliff
        installed=true
    fi

    if command -v git-cliff &> /dev/null; then
        log_success "git-cliff installed: $(git-cliff --version 2>&1)"
    else
        log_error "Failed to install git-cliff"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
