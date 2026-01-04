#!/usr/bin/env bash
# Uninstall script for nginx on Linux
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

# Check if nginx is installed
is_nginx_installed() {
    if command -v nginx &> /dev/null; then
        return 0
    fi
    return 1
}

# Stop nginx service
stop_service() {
    log_info "Stopping nginx service..."

    if command -v systemctl &> /dev/null; then
        sudo systemctl stop nginx 2>/dev/null || true
        sudo systemctl disable nginx 2>/dev/null || true
        log_info "nginx service stopped and disabled"
    fi
}

# Uninstall nginx with retry
uninstall_nginx() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_warn "This will remove nginx and stop any running nginx instances."

    log_info "Uninstalling nginx using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get remove -y nginx nginx-common 2>&1; then
                    sudo apt-get autoremove -y 2>&1 || true
                    log_success "nginx uninstalled successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf remove -y nginx 2>&1; then
                    log_success "nginx uninstalled successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum remove -y nginx 2>&1; then
                    log_success "nginx uninstalled successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -R --noconfirm nginx 2>&1; then
                    log_success "nginx uninstalled successfully"
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

    log_error "Failed to uninstall nginx after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying nginx uninstallation..."

    if is_nginx_installed; then
        log_error "nginx is still installed"
        return 1
    fi

    log_success "nginx has been removed from the system"
    log_info "Note: Configuration files in /etc/nginx may still exist"
    return 0
}

# Main entry point
main() {
    log_info "Starting nginx uninstallation on Linux..."

    if ! is_nginx_installed; then
        log_info "nginx is not installed, nothing to uninstall"
        exit 0
    fi

    local nginx_version
    nginx_version=$(nginx -v 2>&1)
    log_info "Current nginx installation: ${nginx_version}"

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    stop_service
    uninstall_nginx "$package_manager"
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
