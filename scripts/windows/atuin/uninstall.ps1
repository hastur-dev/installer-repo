# Uninstall script for atuin on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting atuin uninstallation on Windows..."
    try { cargo uninstall atuin 2>&1 | Out-Null } catch {}
    Write-LogSuccess "atuin uninstalled"
    Write-LogInfo "Remember to remove atuin init from your PowerShell profile"
    exit 0
}

Main
