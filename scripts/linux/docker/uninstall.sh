#!/usr/bin/env bash
# Uninstall script for Docker on Linux
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

# Check if Docker is installed
is_docker_installed() {
    if command -v docker &> /dev/null; then
        return 0
    fi
    return 1
}

# Stop Docker service
stop_docker_service() {
    log_info "Stopping Docker service..."
    sudo systemctl stop docker 2>&1 || true
    sudo systemctl disable docker 2>&1 || true
    log_info "Docker service stopped"
}

# Uninstall Docker with retry
uninstall_docker() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Uninstalling Docker using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get remove -y docker.io docker-ce docker-ce-cli containerd.io 2>&1; then
                    log_success "Docker uninstalled successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf remove -y docker docker-ce docker-ce-cli containerd.io 2>&1; then
                    log_success "Docker uninstalled successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum remove -y docker docker-ce docker-ce-cli containerd.io 2>&1; then
                    log_success "Docker uninstalled successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -R --noconfirm docker 2>&1; then
                    log_success "Docker uninstalled successfully"
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

    log_error "Failed to uninstall Docker after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying Docker uninstallation..."

    if is_docker_installed; then
        log_error "Docker is still installed"
        return 1
    fi

    log_success "Docker has been removed"
    log_warn "Docker data in /var/lib/docker may still exist. Remove manually if needed."
    return 0
}

# Main entry point
main() {
    log_info "Starting Docker uninstallation on Linux..."

    if ! is_docker_installed; then
        log_info "Docker is not installed, nothing to uninstall"
        exit 0
    fi

    local docker_version
    docker_version=$(docker --version 2>&1)
    log_info "Current Docker installation: ${docker_version}"

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    stop_docker_service
    uninstall_docker "$package_manager"
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
