# Uninstall script for Zsh on Windows
# Provides guidance for removing Zsh from WSL

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "uninstall-windows.ps1"

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

# Check if running on Windows
function Test-WindowsEnvironment {
    Write-LogInfo "Verifying Windows environment..."
    if (-not $IsWindows -and $env:OS -ne "Windows_NT") {
        Write-LogError "This script requires Windows"
        return $false
    }
    Write-LogInfo "Confirmed Windows environment"
    return $true
}

# Check if WSL is available
function Test-WSLInstalled {
    try {
        $null = Get-Command wsl -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Zsh uninstallation guidance on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    Write-LogWarn "Zsh is not natively installed on Windows."
    Write-Host ""

    if (Test-WSLInstalled) {
        Write-LogInfo "WSL is installed on your system."
        Write-LogInfo "To uninstall Zsh from WSL, run the following commands:"
        Write-Host ""
        Write-LogInfo "  wsl"
        Write-LogInfo "  # First, change your default shell if Zsh is the default:"
        Write-LogInfo "  chsh -s /bin/bash"
        Write-LogInfo "  # Then uninstall Zsh:"
        Write-LogInfo "  sudo apt-get remove -y zsh"
        Write-Host ""
    } else {
        Write-LogInfo "WSL is not installed. Zsh was likely not installed via this system."
    }

    Write-LogInfo "If you installed Zsh via other means (Cygwin, MSYS2, Git Bash),"
    Write-LogInfo "please use the respective package manager to uninstall it."

    Write-LogSuccess "Guidance complete!"
    exit 0
}

Main
