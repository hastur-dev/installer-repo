#!/usr/bin/env bash
# Install script for lazydocker on Linux
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

# Install lazydocker via package manager
install_lazydocker_via_pm() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Installing lazydocker using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                # lazydocker is not in standard apt repos, use script
                return 1
                ;;
            dnf)
                sudo dnf copr enable -y atim/lazydocker 2>&1 || true
                if sudo dnf install -y lazydocker 2>&1; then
                    log_success "lazydocker installed successfully"
                    return 0
                fi
                ;;
            yum)
                return 1
                ;;
            pacman)
                if sudo pacman -S --noconfirm lazydocker 2>&1; then
                    log_success "lazydocker installed successfully"
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

    return 1
}

# Install lazydocker via official script
install_lazydocker_via_script() {
    log_info "Installing lazydocker via official script..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>&1; then
            log_success "lazydocker installed successfully via script"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install lazydocker via script after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Install lazydocker
install_lazydocker() {
    local package_manager="$1"

    # Try package manager first
    if install_lazydocker_via_pm "$package_manager"; then
        return 0
    fi

    log_info "Package manager install failed, trying official script..."

    # Fall back to official script
    if install_lazydocker_via_script; then
        return 0
    fi

    log_error "Failed to install lazydocker"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying lazydocker installation..."

    # Check common install locations
    if [ -f "$HOME/.local/bin/lazydocker" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if ! command -v lazydocker &> /dev/null; then
        log_error "lazydocker command not found after installation"
        return 1
    fi

    local lazydocker_version
    lazydocker_version=$(lazydocker --version 2>&1)

    if [ -z "$lazydocker_version" ]; then
        log_error "Could not retrieve lazydocker version"
        return 1
    fi

    log_success "lazydocker verified: ${lazydocker_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting lazydocker installation on Linux..."

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    install_lazydocker "$package_manager"
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
