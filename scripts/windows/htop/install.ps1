# Install script for htop on Windows
# Note: htop is not natively available on Windows
# This script provides alternatives and information

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
    Write-LogInfo "htop installation check on Windows..."
    Write-LogWarn "htop is a Linux/Unix-specific tool and is not available natively on Windows."
    Write-Host ""
    Write-LogInfo "Windows alternatives for process monitoring:"
    Write-LogInfo "  - Task Manager (built-in): Press Ctrl+Shift+Esc"
    Write-LogInfo "  - Resource Monitor (built-in): Run 'resmon' from command line"
    Write-LogInfo "  - Process Explorer: Download from Microsoft Sysinternals"
    Write-LogInfo "  - btop4win: Windows port of btop (similar to htop)"
    Write-Host ""
    Write-LogInfo "If you need htop specifically, you can use:"
    Write-LogInfo "  - WSL (Windows Subsystem for Linux): Install htop inside WSL"
    Write-LogInfo "  - Cygwin or MSYS2: Unix-like environments for Windows"
    Write-Host ""
    Write-LogSuccess "No installation performed - htop is not supported on Windows."
    exit 0
}

Main
