# Install script for ncdu on Windows
# Note: ncdu is not natively available on Windows

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
    Write-LogInfo "ncdu installation check on Windows..."
    Write-LogWarn "ncdu is a Linux/Unix-specific tool and is not available natively on Windows."
    Write-Host ""
    Write-LogInfo "Windows alternatives for disk usage analysis:"
    Write-LogInfo "  - WinDirStat: Visual disk usage analyzer (free)"
    Write-LogInfo "  - TreeSize Free: Disk space manager with tree view"
    Write-LogInfo "  - SpaceSniffer: Visual disk space analyzer"
    Write-LogInfo "  - WizTree: Fast disk space analyzer"
    Write-Host ""
    Write-LogInfo "If you need ncdu specifically, you can use:"
    Write-LogInfo "  - WSL (Windows Subsystem for Linux): Install ncdu inside WSL"
    Write-LogInfo "  - Cygwin or MSYS2: Unix-like environments for Windows"
    Write-Host ""
    Write-LogSuccess "No installation performed - ncdu is not supported on Windows."
    exit 0
}

Main
