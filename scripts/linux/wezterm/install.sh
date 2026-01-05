#!/usr/bin/env bash
set -euo pipefail
readonly SCRIPT_NAME="install.sh"
log_info() { echo "[INFO] ${SCRIPT_NAME}: $1"; }
log_error() { echo "[ERROR] ${SCRIPT_NAME}: $1" >&2; }
log_success() { echo "[SUCCESS] ${SCRIPT_NAME}: $1"; }

main() {
    log_info "Starting wezterm installation on Linux..."
    local installed=false

    if command -v brew &> /dev/null; then
        brew install --cask wezterm && installed=true
    fi

    if [[ "$installed" == "false" ]] && command -v flatpak &> /dev/null; then
        flatpak install -y flathub org.wezfurlong.wezterm && installed=true
    fi

    if [[ "$installed" == "false" ]]; then
        local version
        version=$(curl -s https://api.github.com/repos/wez/wezterm/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64) arch="x86_64" ;;
            aarch64) arch="aarch64" ;;
        esac
        curl -sL "https://github.com/wez/wezterm/releases/download/${version}/WezTerm-${version}-Ubuntu22.04.AppImage" -o /usr/local/bin/wezterm
        chmod +x /usr/local/bin/wezterm
        installed=true
    fi

    if command -v wezterm &> /dev/null; then
        log_success "wezterm installed: $(wezterm --version 2>&1)"
    else
        log_error "Failed to install wezterm"
        exit 1
    fi
    log_success "Installation complete!"
}
main "$@"
