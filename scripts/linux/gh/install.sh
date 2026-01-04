#!/usr/bin/env bash
# Install script for GitHub CLI (gh) on Linux
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

# Setup GitHub CLI repository for apt
setup_gh_repo_apt() {
    log_info "Setting up GitHub CLI repository for apt..."

    sudo mkdir -p -m 755 /etc/apt/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

    sudo apt-get update -y 2>&1
    log_info "GitHub CLI repository configured"
}

# Setup GitHub CLI repository for dnf/yum
setup_gh_repo_rpm() {
    log_info "Setting up GitHub CLI repository for RPM..."

    sudo dnf install -y 'dnf-command(config-manager)' 2>&1 || sudo yum install -y yum-utils 2>&1
    sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo 2>&1 || \
        sudo yum-config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo 2>&1

    log_info "GitHub CLI repository configured"
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
                setup_gh_repo_apt
                log_info "Package lists updated successfully"
                return 0
                ;;
            dnf)
                setup_gh_repo_rpm
                if sudo dnf check-update 2>&1 || true; then
                    log_info "Package lists updated successfully"
                    return 0
                fi
                ;;
            yum)
                setup_gh_repo_rpm
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

# Install GitHub CLI with retry
install_gh() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Installing GitHub CLI using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                if sudo apt-get install -y gh 2>&1; then
                    log_success "GitHub CLI installed successfully"
                    return 0
                fi
                ;;
            dnf)
                if sudo dnf install -y gh 2>&1; then
                    log_success "GitHub CLI installed successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum install -y gh 2>&1; then
                    log_success "GitHub CLI installed successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -S --noconfirm github-cli 2>&1; then
                    log_success "GitHub CLI installed successfully"
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

    log_error "Failed to install GitHub CLI after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying GitHub CLI installation..."

    if ! command -v gh &> /dev/null; then
        log_error "gh command not found after installation"
        return 1
    fi

    local gh_version
    gh_version=$(gh --version 2>&1 | head -n1)

    if [ -z "$gh_version" ]; then
        log_error "Could not retrieve GitHub CLI version"
        return 1
    fi

    log_success "GitHub CLI verified: ${gh_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting GitHub CLI installation on Linux..."

    local package_manager
    package_manager=$(detect_package_manager)

    if [ -z "$package_manager" ]; then
        log_error "Failed to detect package manager"
        exit 1
    fi

    log_info "Detected package manager: ${package_manager}"

    update_package_lists "$package_manager"
    install_gh "$package_manager"
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
