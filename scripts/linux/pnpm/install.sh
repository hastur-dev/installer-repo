#!/usr/bin/env bash
# Install script for pnpm on Linux
# Uses npm or corepack for installation

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2

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

# Check if Node.js is installed
is_node_installed() {
    if command -v node &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if npm is installed
is_npm_installed() {
    if command -v npm &> /dev/null; then
        return 0
    fi
    return 1
}

# Check if corepack is available
is_corepack_available() {
    if command -v corepack &> /dev/null; then
        return 0
    fi
    return 1
}

# Install pnpm via corepack (preferred)
install_pnpm_via_corepack() {
    log_info "Installing pnpm via corepack..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if corepack enable 2>&1 && corepack prepare pnpm@latest --activate 2>&1; then
            log_success "pnpm installed successfully via corepack"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    return 1
}

# Install pnpm via npm
install_pnpm_via_npm() {
    log_info "Installing pnpm via npm..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if npm install -g pnpm 2>&1; then
            log_success "pnpm installed successfully via npm"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install pnpm via npm after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Install pnpm via standalone script
install_pnpm_via_script() {
    log_info "Installing pnpm via standalone script..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if curl -fsSL https://get.pnpm.io/install.sh | sh - 2>&1; then
            log_success "pnpm installed successfully via standalone script"
            # Source pnpm environment
            export PNPM_HOME="$HOME/.local/share/pnpm"
            export PATH="$PNPM_HOME:$PATH"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    return 1
}

# Install pnpm
install_pnpm() {
    # Try corepack first (modern Node.js)
    if is_corepack_available; then
        if install_pnpm_via_corepack; then
            return 0
        fi
        log_info "Corepack installation failed, falling back to npm..."
    fi

    # Fall back to npm
    if is_npm_installed; then
        if install_pnpm_via_npm; then
            return 0
        fi
        log_info "npm installation failed, trying standalone script..."
    fi

    # Fall back to standalone script
    if install_pnpm_via_script; then
        return 0
    fi

    log_error "Failed to install pnpm"
    return 1
}

# Verify installation
verify_installation() {
    log_info "Verifying pnpm installation..."

    # Refresh PATH
    hash -r 2>/dev/null || true

    # Add pnpm to path if installed via standalone script
    if [ -d "$HOME/.local/share/pnpm" ]; then
        export PNPM_HOME="$HOME/.local/share/pnpm"
        export PATH="$PNPM_HOME:$PATH"
    fi

    if ! command -v pnpm &> /dev/null; then
        log_error "pnpm command not found after installation"
        return 1
    fi

    local pnpm_version
    pnpm_version=$(pnpm --version 2>&1)

    if [ -z "$pnpm_version" ]; then
        log_error "Could not retrieve pnpm version"
        return 1
    fi

    log_success "pnpm verified: ${pnpm_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting pnpm installation on Linux..."

    if ! is_node_installed; then
        log_error "Node.js is not installed. Please install Node.js first."
        exit 1
    fi

    local node_version
    node_version=$(node --version 2>&1)
    log_info "Node.js version: ${node_version}"

    install_pnpm
    verify_installation

    log_success "Installation complete!"
    exit 0
}

main "$@"
