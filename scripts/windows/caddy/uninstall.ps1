# Uninstall script for caddy on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting caddy uninstallation on Windows..."

    try { winget uninstall --id CaddyServer.Caddy --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall caddy -y --no-progress 2>&1 | Out-Null } catch {}
    try { scoop uninstall caddy 2>&1 | Out-Null } catch {}

    Write-LogSuccess "caddy uninstalled"
    exit 0
}

Main
