# Uninstall script for ncdu on Windows
# Note: ncdu is not natively available on Windows

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

function Write-LogSuccess {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green
}

# Main entry point
function Main {
    Write-LogInfo "ncdu uninstallation check on Windows..."
    Write-LogInfo "ncdu is not available on Windows natively."
    Write-LogInfo "Nothing to uninstall."
    Write-LogSuccess "No changes made."
    exit 0
}

Main
