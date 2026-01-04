# Uninstall script for Starship on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall-windows.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting Starship uninstallation on Windows..."

    try { winget uninstall --id Starship.Starship --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall starship -y --no-progress 2>&1 | Out-Null } catch {}

    Write-LogSuccess "Starship uninstalled"
    Write-LogInfo "Remember to remove Starship init from your PowerShell profile"
    exit 0
}

Main
