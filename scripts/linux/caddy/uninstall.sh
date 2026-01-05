#!/usr/bin/env bash
# Uninstall script for caddy on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting caddy uninstallation on Linux..."

    command -v apt-get &> /dev/null && apt-get remove -y -qq caddy 2>/dev/null || true
    rm -f /etc/apt/sources.list.d/caddy-stable.list 2>/dev/null || true
    rm -f /usr/share/keyrings/caddy-stable-archive-keyring.gpg 2>/dev/null || true
    command -v dnf &> /dev/null && dnf remove -y -q caddy 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall caddy 2>/dev/null || true

    log_success "caddy uninstalled"
    exit 0
}

main "$@"
