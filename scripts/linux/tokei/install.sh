#!/usr/bin/env bash
# Install script for tokei on Linux

set -euo pipefail

readonly SCRIPT_NAME="install.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly SUPPORTED_PACKAGE_MANAGERS=("apt-get" "dnf" "yum" "pacman")

log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
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

install_tokei() {
    local package_manager="$1"
    log_info "Installing tokei using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        case "$package_manager" in
            apt-get)
                if sudo apt-get update -y && sudo apt-get install -y tokei 2>&1; then
                    log_success "tokei installed successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y tokei 2>&1; then
                    log_success "tokei installed successfully"
                    return 0
                fi
                ;;
            yum)
                if command -v cargo &> /dev/null; then
                    if cargo install tokei --locked 2>&1; then
                        log_success "tokei installed via cargo"
                        return 0
                    fi
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm tokei 2>&1; then
                    log_success "tokei installed successfully"
                    return 0
                fi
                ;;
        esac
        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done
    return 1
}

verify_installation() {
    log_info "Verifying tokei installation..."
    if ! command -v tokei &> /dev/null; then
        log_error "tokei command not found"
        return 1
    fi
    local version
    version=$(tokei --version 2>&1)
    log_success "tokei verified: ${version}"
    return 0
}

main() {
    log_info "Starting tokei installation on Linux..."
    local package_manager
    package_manager=$(detect_package_manager) || {
        log_error "No supported package manager found"
        exit 1
    }
    install_tokei "$package_manager"
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
