#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting mdbook installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install mdbook && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/rust-lang/mdBook/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="aarch64" ;;
        esac
        curl -sL "https://github.com/rust-lang/mdBook/releases/download/v${version}/mdbook-v${version}-${arch}-unknown-linux-gnu.tar.gz" | tar xz -C /usr/local/bin
        chmod +x /usr/local/bin/mdbook
        installed=true
    fi

    if command -v mdbook &> /dev/null; then
        log_success "mdbook installed: $(mdbook --version 2>&1)"
    else
        log_error "Failed to install mdbook"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
