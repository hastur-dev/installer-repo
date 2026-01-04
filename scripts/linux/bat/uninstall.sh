#!/usr/bin/env bash
# Uninstall script for bat on Linux
# Supports Debian/Ubuntu (apt), Fedora/RHEL (dnf/yum), and Arch (pacman)

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly SUPPORTED_PACKAGE_MANAGERS=("apt-get" "dnf" "yum" "pacman")

# Logging functions
log_info() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_info: message cannot be empty" >&2
        return 1
    fi
    echo "[INFO] ${SCRIPT_NAME}: ${message}"
}

log_error() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_error: message cannot be empty" >&2
        return 1
    fi
    echo "[ERROR] ${SCRIPT_NAME}: ${message}" >&2
}

log_success() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_success: message cannot be empty" >&2
        return 1
    fi
    echo "[SUCCESS] ${SCRIPT_NAME}: ${message}"
}

log_warn() {
    local message="$1"
    if [ -z "$message" ]; then
        echo "[ERROR] log_warn: message cannot be empty" >&2
        return 1
    fi
    echo "[WARN] ${SCRIPT_NAME}: ${message}"
}

# Detect package manager
detect_package_manager() {
    local detected=""
    local iteration=0

    for pm in "${SUPPORTED_PACKAGE_MANAGERS[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt 10 ]; then
            log_error "Exceeded iteration limit in detect_package_manager"
            return 1
        fi

        if command -v "$pm" &> /dev/null; then
            detected="$pm"
            break
        fi
    done

    if [ -z "$detected" ]; then
        log_error "No supported package manager found"
        return 1
    fi

    echo "$detected"
}

# Check if bat is installed
is_bat_installed() {
    if command -v bat &> /dev/null || command -v batcat &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall bat with retry
uninstall_bat() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Uninstalling bat using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get remove -y bat 2>&1; then
                    log_success "bat uninstalled successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf remove -y bat 2>&1; then
                    log_success "bat uninstalled successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum remove -y bat 2>&1; then
                    log_success "bat uninstalled successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -R --noconfirm bat 2>&1; then
                    log_success "bat uninstalled successfully"
                    return 0
                fi
                ;;
            *)
                log_error "Unknown package manager: ${package_manager}"
                return 1
                ;;
        esac

        log_info "Uninstall failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to uninstall bat after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying bat uninstallation..."

    if is_bat_installed; then
        log_error "bat is still installed"
        return 1
    fi

    log_success "bat has been removed"
    return 0
}

# Main entry point
main() {
    log_info "Starting bat uninstallation on Linux..."

    if ! is_bat_installed; then
        log_info "bat is not installed, nothing to uninstall"
        exit 0
    fi

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    uninstall_bat "$package_manager"
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
