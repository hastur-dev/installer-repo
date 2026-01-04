#!/usr/bin/env bash
# Uninstall script for Deno on Linux
# Removes Deno installed via official installer

set -euo pipefail

# Constants
readonly SCRIPT_NAME="uninstall-linux.sh"

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

# Check if Deno is installed
is_deno_installed() {
    local deno_install="${DENO_INSTALL:-$HOME/.deno}"
    if [ -f "$deno_install/bin/deno" ]; then
        return 0
    fi
    if command -v deno &> /dev/null; then
        return 0
    fi
    return 1
}

# Uninstall Deno
uninstall_deno() {
    log_info "Uninstalling Deno..."

    local deno_install="${DENO_INSTALL:-$HOME/.deno}"

    # Remove Deno directory
    if [ -d "$deno_install" ]; then
        log_info "Removing Deno installation directory: $deno_install"
        rm -rf "$deno_install"
        log_success "Deno directory removed"
    else
        log_info "Deno directory not found at $deno_install"
    fi

    # Clean up shell config
    local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    for config in "${shell_configs[@]}"; do
        if [ -f "$config" ]; then
            if grep -q "DENO_INSTALL" "$config" 2>/dev/null; then
                log_info "Cleaning Deno entries from $config"
                # Create backup
                cp "$config" "${config}.backup"
                # Remove Deno-related lines
                grep -v "DENO_INSTALL" "$config" | grep -v "# Deno" > "${config}.tmp" || true
                mv "${config}.tmp" "$config"
            fi
        fi
    done

    return 0
}

# Verify uninstallation
verify_uninstall() {
    log_info "Verifying Deno uninstallation..."

    local deno_install="${DENO_INSTALL:-$HOME/.deno}"

    if [ -d "$deno_install" ]; then
        log_error "Deno directory still exists at $deno_install"
        return 1
    fi

    log_success "Deno has been removed from the system"
    log_info "Note: You may need to restart your shell for changes to take effect"
    return 0
}

# Main entry point
main() {
    log_info "Starting Deno uninstallation on Linux..."

    if ! is_deno_installed; then
        log_info "Deno is not installed, nothing to uninstall"
        exit 0
    fi

    if command -v deno &> /dev/null; then
        local deno_version
        deno_version=$(deno --version 2>&1 | head -n 1)
        log_info "Current Deno installation: ${deno_version}"
    fi

    uninstall_deno
    verify_uninstall

    log_success "Uninstallation complete!"
    exit 0
}

main "$@"
