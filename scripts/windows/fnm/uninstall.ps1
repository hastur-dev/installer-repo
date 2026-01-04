# Uninstall script for fnm on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting fnm uninstallation on Windows..."
    try { winget uninstall --id Schniz.fnm --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall fnm -y --no-progress 2>&1 | Out-Null } catch {}
    if (Test-Path "$env:APPDATA\fnm") { Remove-Item -Recurse -Force "$env:APPDATA\fnm" }
    Write-LogSuccess "fnm uninstalled"
    Write-LogInfo "Remember to remove fnm env from your PowerShell profile"
    exit 0
}

Main
