#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting vagrant installation on Linux..."
    local installed=false

    if command -v apt-get &> /dev/null; then
        curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
        apt-get update -qq && apt-get install -y -qq vagrant && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v brew &> /dev/null; then
        brew install vagrant && installed=true
    fi

    if command -v vagrant &> /dev/null; then
        log_success "vagrant installed: $(vagrant version 2>&1 | head -1)"
    else
        log_error "Failed to install vagrant"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
