#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting poetry uninstallation on Linux..."
    command -v pipx &> /dev/null && pipx uninstall poetry 2>/dev/null || true
    curl -sSL https://install.python-poetry.org | python3 - --uninstall 2>/dev/null || true
    log_success "poetry uninstalled"
}
main "$@"
