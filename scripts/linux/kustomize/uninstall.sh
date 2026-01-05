#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="uninstall.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting kustomize uninstallation on Linux..."
    command -v brew &> /dev/null && brew uninstall kustomize 2>/dev/null || true
    command -v snap &> /dev/null && snap remove kustomize 2>/dev/null || true
    rm -f /usr/local/bin/kustomize 2>/dev/null || true
    log_success "kustomize uninstalled"
}
main "$@"
