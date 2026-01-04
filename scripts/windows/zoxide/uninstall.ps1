# Uninstall script for zoxide on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting zoxide uninstallation on Windows..."

    try { winget uninstall --id ajeetdsouza.zoxide --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall zoxide -y --no-progress 2>&1 | Out-Null } catch {}

    Write-LogSuccess "zoxide uninstalled"
    Write-LogInfo "Remember to remove zoxide init from your PowerShell profile"
    exit 0
}

Main
