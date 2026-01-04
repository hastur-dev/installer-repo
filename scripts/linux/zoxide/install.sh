#!/usr/bin/env bash
# Install script for zoxide on Linux

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

install_zoxide() {
    local package_manager="$1"
    log_info "Installing zoxide using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true
        case "$package_manager" in
            apt-get)
                if sudo apt-get update -y && sudo apt-get install -y zoxide 2>&1; then
                    log_success "zoxide installed successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y zoxide 2>&1; then
                    log_success "zoxide installed successfully"
                    return 0
                fi
                ;;
            yum)
                # yum doesn't have zoxide, use cargo
                if command -v cargo &> /dev/null; then
                    if cargo install zoxide --locked 2>&1; then
                        log_success "zoxide installed via cargo"
                        return 0
                    fi
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm zoxide 2>&1; then
                    log_success "zoxide installed successfully"
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
    log_info "Verifying zoxide installation..."
    if ! command -v zoxide &> /dev/null; then
        log_error "zoxide command not found"
        return 1
    fi
    local version
    version=$(zoxide --version 2>&1)
    log_success "zoxide verified: ${version}"
    log_info "Add to shell config: eval \"\$(zoxide init bash)\" or eval \"\$(zoxide init zsh)\""
    return 0
}

main() {
    log_info "Starting zoxide installation on Linux..."
    local package_manager
    package_manager=$(detect_package_manager) || {
        log_error "No supported package manager found"
        exit 1
    }
    log_info "Detected package manager: ${package_manager}"
    install_zoxide "$package_manager"
    verify_installation
    log_success "Installation complete!"
    exit 0
}

main "$@"
