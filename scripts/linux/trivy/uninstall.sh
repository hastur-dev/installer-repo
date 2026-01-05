#!/usr/bin/env bash
# Uninstall script for trivy on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting trivy uninstallation on Linux..."

    command -v apt-get &> /dev/null && apt-get remove -y -qq trivy 2>/dev/null || true
    rm -f /etc/apt/sources.list.d/trivy.list 2>/dev/null || true
    rm -f /usr/share/keyrings/trivy.gpg 2>/dev/null || true
    command -v brew &> /dev/null && brew uninstall trivy 2>/dev/null || true
    command -v snap &> /dev/null && snap remove trivy 2>/dev/null || true

    log_success "trivy uninstalled"
    exit 0
}

main "$@"
