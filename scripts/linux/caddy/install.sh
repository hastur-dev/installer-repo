#!/usr/bin/env bash
# Install script for caddy on Linux (web server)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting caddy installation on Linux..."

    local installed=false

    # Try apt with official repo
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq debian-keyring debian-archive-keyring apt-transport-https curl
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' > /etc/apt/sources.list.d/caddy-stable.list
        apt-get update -qq
        apt-get install -y -qq caddy && installed=true
    fi

    # Try dnf (Fedora)
    if [[ "$installed" == "false" ]] && command -v dnf &> /dev/null; then
        dnf install -y -q 'dnf-command(copr)'
        dnf copr enable -y @caddy/caddy
        dnf install -y -q caddy && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install caddy && installed=true
    fi

    if command -v caddy &> /dev/null; then
        log_success "caddy installed: $(caddy version 2>&1)"
    else
        log_error "Failed to install caddy"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
