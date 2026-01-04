# Install script for Zsh on Windows
# Note: Zsh is not natively available on Windows
# This script provides guidance for WSL or Git Bash alternatives

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "install-windows.ps1"
$MAX_RETRY_ATTEMPTS = 3
$RETRY_DELAY_SECONDS = 2

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

# Check if winget is available
function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Install WSL if not present
function Install-WSL {
    Write-LogInfo "Installing WSL..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            if (Test-WingetInstalled) {
                $result = wsl --install --no-distribution 2>&1
                if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                    Write-LogSuccess "WSL installed successfully"
                    Write-LogWarn "A system restart may be required to complete WSL installation"
                    return $true
                }
            }
        } catch {
            Write-LogInfo "WSL install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install WSL after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Main entry point
function Main {
    Write-LogInfo "Starting Zsh installation guidance on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    Write-LogWarn "Zsh is not natively available on Windows."
    Write-Host ""
    Write-LogInfo "Options for using Zsh on Windows:"
    Write-LogInfo "1. WSL (Windows Subsystem for Linux) - Recommended"
    Write-LogInfo "2. Git Bash (limited Zsh support)"
    Write-LogInfo "3. Cygwin or MSYS2"
    Write-Host ""

    if (Test-WSLInstalled) {
        Write-LogInfo "WSL is already installed on your system."
        Write-LogInfo "To install Zsh in WSL, run the following commands:"
        Write-LogInfo "  wsl"
        Write-LogInfo "  sudo apt-get update && sudo apt-get install -y zsh"
        Write-Host ""
        Write-LogInfo "To set Zsh as your default shell in WSL:"
        Write-LogInfo "  chsh -s $(which zsh)"
    } else {
        Write-LogInfo "WSL is not installed. Would you like to install it?"
        $installed = Install-WSL
        if ($installed) {
            Write-LogInfo "After restarting, install a Linux distribution and then install Zsh:"
            Write-LogInfo "  wsl --install -d Ubuntu"
            Write-LogInfo "  wsl"
            Write-LogInfo "  sudo apt-get update && sudo apt-get install -y zsh"
        }
    }

    Write-LogSuccess "Guidance complete!"
    exit 0
}

Main
