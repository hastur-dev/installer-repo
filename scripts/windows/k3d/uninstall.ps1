# Uninstall script for k3d on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "uninstall.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting k3d uninstallation on Windows..."
    try { choco uninstall k3d -y --no-progress 2>&1 | Out-Null } catch {}
    try { scoop uninstall k3d 2>&1 | Out-Null } catch {}
    Write-LogSuccess "k3d uninstalled"
}
Main
