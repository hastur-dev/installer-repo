#!/usr/bin/env bash
# Install script for Docker on Linux
# Supports Debian/Ubuntu (apt), Fedora/RHEL (dnf/yum), and Arch (pacman)

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-linux.sh"
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

# Update package lists with retry
update_package_lists() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Updating package lists using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get update -y 2>&1; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf check-update 2>&1 || true; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum check-update 2>&1 || true; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -Sy --noconfirm 2>&1; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            *)
                log_error "Unknown package manager: ${package_manager}"
                return 1
                ;;
        esac

        log_info "Update failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to update package lists after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Install Docker with retry
install_docker() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Installing Docker using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get install -y docker.io 2>&1; then
                    log_success "Docker installed successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y docker 2>&1; then
                    log_success "Docker installed successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum install -y docker 2>&1; then
                    log_success "Docker installed successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm docker 2>&1; then
                    log_success "Docker installed successfully"
                    return 0
                fi
                ;;
            *)
                log_error "Unknown package manager: ${package_manager}"
                return 1
                ;;
        esac

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install Docker after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Enable and start Docker service
configure_docker_service() {
    log_info "Configuring Docker service..."

    if sudo systemctl enable docker 2>&1; then
        log_info "Docker service enabled"
    fi

    if sudo systemctl start docker 2>&1; then
        log_info "Docker service started"
    fi

    # Add current user to docker group
    if sudo usermod -aG docker "$USER" 2>&1; then
        log_info "Added ${USER} to docker group"
        log_info "Note: You may need to log out and back in for group changes to take effect"
    fi

    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying Docker installation..."

    if ! command -v docker &> /dev/null; then
        log_error "docker command not found after installation"
        return 1
    fi

    local docker_version
    docker_version=$(docker --version 2>&1)

    if [ -z "$docker_version" ]; then
        log_error "Could not retrieve Docker version"
        return 1
    fi

    log_success "Docker verified: ${docker_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting Docker installation on Linux..."

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    update_package_lists "$package_manager"
    install_docker "$package_manager"
    configure_docker_service
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
