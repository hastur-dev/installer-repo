# Uninstall script for hexyl on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting hexyl uninstallation on Windows..."
    try { choco uninstall hexyl -y --no-progress 2>&1 | Out-Null } catch {}
    try { cargo uninstall hexyl 2>&1 | Out-Null } catch {}
    Write-LogSuccess "hexyl uninstalled"
    exit 0
}

Main
