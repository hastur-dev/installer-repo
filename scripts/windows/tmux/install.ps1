# Install script for tmux on Windows
# Note: tmux is not natively available on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "install-windows.ps1"

# Logging functions
function Write-LogInfo {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[INFO] ${SCRIPT_NAME}: $Message"
}

function Write-LogError {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red
}

function Write-LogSuccess {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green
}

function Write-LogWarn {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow
}

# Main entry point
function Main {
    Write-LogInfo "tmux installation check on Windows..."
    Write-LogWarn "tmux is a Linux/Unix-specific tool and is not available natively on Windows."
    Write-Host ""
    Write-LogInfo "Windows alternatives for terminal multiplexing:"
    Write-LogInfo "  - Windows Terminal: Built-in tabbed terminal with pane support"
    Write-LogInfo "  - ConEmu: Feature-rich terminal emulator with tabs and splits"
    Write-LogInfo "  - Cmder: Console emulator with tabs and split views"
    Write-LogInfo "  - Terminus: Modern terminal with split views"
    Write-Host ""
    Write-LogInfo "If you need tmux specifically, you can use:"
    Write-LogInfo "  - WSL (Windows Subsystem for Linux): Install tmux inside WSL"
    Write-LogInfo "  - Cygwin or MSYS2: Unix-like environments for Windows"
    Write-LogInfo "  - Git Bash with MSYS2: Provides tmux via pacman"
    Write-Host ""
    Write-LogSuccess "No installation performed - tmux is not supported on Windows."
    exit 0
}

Main
