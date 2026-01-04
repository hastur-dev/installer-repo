#!/usr/bin/env bash
# Install script for Deno on Linux
# Uses official Deno installer

set -euo pipefail

# Constants
readonly SCRIPT_NAME="install-linux.sh"
readonly MAX_RETRY_ATTEMPTS=3
readonly RETRY_DELAY_SECONDS=2
readonly DENO_INSTALL_URL="https://deno.land/install.sh"

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

# Check for curl
ensure_curl() {
    log_info "Checking for curl..."

    if command -v curl &> /dev/null; then
        log_info "curl is available"
        return 0
    fi

    log_error "curl is required but not installed"
    log_info "Please install curl first using your package manager"
    return 1
}

# Install Deno with retry
install_deno() {
    log_info "Installing Deno from official installer..."

    local attempt=0
    while [ $attempt -lt $MAX_RETRY_ATTEMPTS ]; do
        ((attempt++)) || true

        if curl -fsSL ${DENO_INSTALL_URL} | sh 2>&1; then
            log_success "Deno installed successfully"
            return 0
        fi

        log_info "Install failed, retrying (${attempt}/${MAX_RETRY_ATTEMPTS})..."
        sleep $RETRY_DELAY_SECONDS
    done

    log_error "Failed to install Deno after ${MAX_RETRY_ATTEMPTS} attempts"
    return 1
}

# Setup PATH
setup_path() {
    log_info "Setting up PATH..."

    local deno_install="${DENO_INSTALL:-$HOME/.deno}"
    local deno_bin="$deno_install/bin"

    if [[ ":$PATH:" != *":$deno_bin:"* ]]; then
        export PATH="$deno_bin:$PATH"
    fi

    # Add to shell config
    local shell_config=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    elif [ -f "$HOME/.profile" ]; then
        shell_config="$HOME/.profile"
    fi

    if [ -n "$shell_config" ]; then
        if ! grep -q "DENO_INSTALL" "$shell_config" 2>/dev/null; then
            log_info "Adding Deno to $shell_config"
            echo "" >> "$shell_config"
            echo "# Deno" >> "$shell_config"
            echo "export DENO_INSTALL=\"$deno_install\"" >> "$shell_config"
            echo "export PATH=\"\$DENO_INSTALL/bin:\$PATH\"" >> "$shell_config"
        fi
    fi

    log_info "PATH configured for Deno"
}

# Verify installation
verify_installation() {
    log_info "Verifying Deno installation..."

    local deno_install="${DENO_INSTALL:-$HOME/.deno}"
    local deno_bin="$deno_install/bin/deno"

    if [ ! -f "$deno_bin" ]; then
        # Try system PATH
        if ! command -v deno &> /dev/null; then
            log_error "deno command not found after installation"
            return 1
        fi
        deno_bin="deno"
    fi

    local deno_version
    deno_version=$("$deno_bin" --version 2>&1 | head -n 1)

    if [ -z "$deno_version" ]; then
        log_error "Could not retrieve Deno version"
        return 1
    fi

    log_success "Deno verified: ${deno_version}"
    return 0
}

# Main entry point
main() {
    log_info "Starting Deno installation on Linux..."

    ensure_curl
    install_deno
    setup_path
    verify_installation

    log_success "Installation complete!"
    log_info "Note: You may need to restart your shell or run 'source ~/.bashrc' to use deno"
    exit 0
}

main "$@"
