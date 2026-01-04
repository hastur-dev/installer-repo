#!/usr/bin/env bash
# Uninstall script for lazydocker on Linux
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

# Check if lazydocker is installed
is_lazydocker_installed() {
    if command -v lazydocker &> /dev/null; then
        return 0
    fi
    # Check local bin
    if [ -f "$HOME/.local/bin/lazydocker" ]; then
        return 0
    fi
    return 1
}

# Uninstall lazydocker via package manager
uninstall_lazydocker_via_pm() {
    local package_manager="$1"

    if [ -z "$package_manager" ]; then
        log_error "package_manager parameter is required"
        return 1
    fi

    log_info "Uninstalling lazydocker using ${package_manager}..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        case "$package_manager" in
            apt-get)
                # Not in standard apt repos
                return 1
                ;;
            dnf)
                if sudo dnf remove -y lazydocker 2>&1; then
                    log_success "lazydocker uninstalled successfully"
                    return 0
                fi
                ;;
            yum)
                if sudo yum remove -y lazydocker 2>&1; then
                    log_success "lazydocker uninstalled successfully"
                    return 0
                fi
                ;;
            pacman)
                if sudo pacman -R --noconfirm lazydocker 2>&1; then
                    log_success "lazydocker uninstalled successfully"
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

    return 1
}

# Remove manually installed lazydocker
remove_manual_install() {
    log_info "Removing manually installed lazydocker..."

    local removed=false

    # Check common locations
    if [ -f "$HOME/.local/bin/lazydocker" ]; then
        rm -f "$HOME/.local/bin/lazydocker"
        log_success "Removed lazydocker from ~/.local/bin/"
        removed=true
    fi

    if [ -f "/usr/local/bin/lazydocker" ]; then
        sudo rm -f "/usr/local/bin/lazydocker"
        log_success "Removed lazydocker from /usr/local/bin/"
        removed=true
    fi

    if $removed; then
        return 0
    fi

    return 1
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying lazydocker uninstallation..."

    # Refresh PATH
    hash -r 2>/dev/null || true

    if is_lazydocker_installed; then
        log_warn "lazydocker is still available"
        return 1
    fi

    log_success "lazydocker has been removed"
    return 0
}

# Main entry point
main() {
    log_info "Starting lazydocker uninstallation on Linux..."

    if ! is_lazydocker_installed; then
        log_info "lazydocker is not installed, nothing to uninstall"
        exit 0
    fi

    local lazydocker_version
    lazydocker_version=$(lazydocker --version 2>&1 || echo "unknown")
    log_info "Current lazydocker installation: ${lazydocker_version}"

    local package_manager
    package_manager=$(detect_package_manager)

    local uninstalled=false

    # Try package manager first
    if [ -n "$package_manager" ]; then
        log_info "Detected package manager: ${package_manager}"
        if uninstall_lazydocker_via_pm "$package_manager"; then
            uninstalled=true
        fi
    fi

    # Try manual removal
    if ! $uninstalled; then
        if remove_manual_install; then
            uninstalled=true
        fi
    fi

    if ! $uninstalled; then
        log_warn "Could not uninstall lazydocker via any method"
        log_info "You may need to manually remove it"
    fi

    verify_uninstall || true

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
