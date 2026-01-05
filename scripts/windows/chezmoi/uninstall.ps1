# Uninstall script for chezmoi on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting chezmoi uninstallation on Windows..."

    try { winget uninstall --id twpayne.chezmoi --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall chezmoi -y --no-progress 2>&1 | Out-Null } catch {}
    try { scoop uninstall chezmoi 2>&1 | Out-Null } catch {}

    Write-LogSuccess "chezmoi uninstalled"
    exit 0
}

Main
