#!/usr/bin/env bash
# Install script for kubectl on Linux
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

# Setup Kubernetes repository for apt
setup_kubernetes_repo_apt() {
    log_info "Setting up Kubernetes repository for apt..."

    # Install prerequisites
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg 2>&1

    # Create keyrings directory
    sudo mkdir -p /etc/apt/keyrings

    # Download signing key
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 2>&1

    # Add repository
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

    sudo apt-get update -y 2>&1
    log_info "Kubernetes repository configured"
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
                setup_kubernetes_repo_apt
                log_info "Package lists updated successfully"
                return 0
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

# Install kubectl with retry
install_kubectl() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Installing kubectl using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get install -y kubectl 2>&1; then
                    log_success "kubectl installed successfully"
                    return 0
                fi
                ;;
            dnf)
                # Install via direct download for dnf
                if install_kubectl_binary; then
                    log_success "kubectl installed successfully"
                    return 0
                fi
                ;;
            yum)
                # Install via direct download for yum
                if install_kubectl_binary; then
                    log_success "kubectl installed successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm kubectl 2>&1; then
                    log_success "kubectl installed successfully"
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

    log_error "Failed to install kubectl after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Install kubectl binary directly
install_kubectl_binary() {
    log_info "Installing kubectl via direct binary download..."

    local kubectl_version
    kubectl_version=$(curl -L -s https://dl.k8s.io/release/stable.txt)

    curl -LO "https://dl.k8s.io/release/${kubectl_version}/bin/linux/amd64/kubectl" 2>&1
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 2>&1
    rm -f kubectl

    return 0
}

# Verify installation
verify_installation() {
    log_info "Verifying kubectl installation..."

    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl command not found after installation"
        return 1
    fi

    local kubectl_version
    kubectl_version=$(kubectl version --client 2>&1)

    if [ -z "$kubectl_version" ]; then
        log_error "Could not retrieve kubectl version"
        return 1
    fi

    log_success "kubectl verified: ${kubectl_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting kubectl installation on Linux..."

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    update_package_lists "$package_manager"
    install_kubectl "$package_manager"
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
