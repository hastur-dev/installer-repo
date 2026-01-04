#!/usr/bin/env bash
# Uninstall script for tokei on Linux

set -euo pipefail

readonly SCRIPT_NAME="uninstall.sh"
readonly SUPPORTED_PACKAGE_MANAGERS=("apt-get" "dnf" "yum" "pacman")

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

detect_package_manager() {
    for pm in "${SUPPORTED_PACKAGE_MANAGERS[@]}"; do
        if command -v "$pm" &> /dev/null; then
            echo "$pm"
            return 0
        fi
    done
    return 1
}

main() {
    log_info "Starting tokei uninstallation on Linux..."

    if ! command -v tokei &> /dev/null; then
        log_info "tokei is not installed"
        exit 0
    fi

    local package_manager
    package_manager=$(detect_package_manager) || true

    case "$package_manager" in
        apt-get) sudo apt-get remove -y tokei 2>&1 || true ;;
        dnf) sudo dnf remove -y tokei 2>&1 || true ;;
        pacman) sudo pacman -R --noconfirm tokei 2>&1 || true ;;
    esac

    if command -v cargo &> /dev/null; then
        cargo uninstall tokei 2>&1 || true
    fi

    log_success "tokei uninstalled"
    exit 0
}

main "$@"
