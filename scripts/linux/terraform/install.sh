#!/usr/bin/env bash
# Install script for Terraform on Linux
# Supports Debian/Ubuntu (apt), Fedora/RHEL (dnf/yum), and Arch (pacman)
# Uses HashiCorp repository for apt/dnf/yum

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

# Setup HashiCorp repository for apt
setup_hashicorp_repo_apt() {
    log_info "Setting up HashiCorp repository for apt..."

    # Install prerequisites
    sudo apt-get install -y gnupg software-properties-common curl 2>&1

    # Add HashiCorp GPG key
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 2>&1

    # Add repository
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

    sudo apt-get update -y 2>&1
    log_info "HashiCorp repository configured"
}

# Setup HashiCorp repository for dnf/yum
setup_hashicorp_repo_rpm() {
    log_info "Setting up HashiCorp repository for RPM..."

    sudo yum install -y yum-utils 2>&1 || sudo dnf install -y dnf-plugins-core 2>&1

    sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 2>&1 || \
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo 2>&1

    log_info "HashiCorp repository configured"
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
                setup_hashicorp_repo_apt
                log_info "Package lists updated successfully"
                return 0
                ;;
            dnf)
                setup_hashicorp_repo_rpm
                if sudo dnf check-update 2>&1 || true; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            yum)
                setup_hashicorp_repo_rpm
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

# Install Terraform with retry
install_terraform() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Installing Terraform using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get install -y terraform 2>&1; then
                    log_success "Terraform installed successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y terraform 2>&1; then
                    log_success "Terraform installed successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum install -y terraform 2>&1; then
                    log_success "Terraform installed successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm terraform 2>&1; then
                    log_success "Terraform installed successfully"
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

    log_error "Failed to install Terraform after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying Terraform installation..."

    if ! command -v terraform &> /dev/null; then
        log_error "terraform command not found after installation"
        return 1
    fi

    local terraform_version
    terraform_version=$(terraform --version 2>&1 | head -n1)

    if [ -z "$terraform_version" ]; then
        log_error "Could not retrieve Terraform version"
        return 1
    fi

    log_success "Terraform verified: ${terraform_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting Terraform installation on Linux..."

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    update_package_lists "$package_manager"
    install_terraform "$package_manager"
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
