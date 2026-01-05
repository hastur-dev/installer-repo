#!/usr/bin/env bash
# Install script for trivy on Linux (security scanner)

set -euo pipefail

readonly SCRIPT_NAME="install.sh"

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting trivy installation on Linux..."

    local installed=false

    # Try apt with official repo
    if command -v apt-get &> /dev/null; then
        apt-get update -qq
        apt-get install -y -qq wget apt-transport-https gnupg lsb-release
        wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /usr/share/keyrings/trivy.gpg
        echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" > /etc/apt/sources.list.d/trivy.list
        apt-get update -qq
        apt-get install -y -qq trivy && installed=true
    fi

    # Try brew
    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install trivy && installed=true
    fi

    # Try snap
    if [[ "$installed" == "false" ]] && command -v snap &> /dev/null; then
        snap install trivy && installed=true
    fi

    if command -v trivy &> /dev/null; then
        log_success "trivy installed: $(trivy version 2>&1 | head -1)"
    else
        log_error "Failed to install trivy"
        exit 1
    fi

    log_success "Installation complete!"
    exit 0
}

main "$@"
