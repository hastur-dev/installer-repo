# Uninstall script for kind on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting kind uninstallation on Windows..."

    try { winget uninstall --id Kubernetes.kind --silent 2>&1 | Out-Null } catch {}
    try { choco uninstall kind -y --no-progress 2>&1 | Out-Null } catch {}
    try { scoop uninstall kind 2>&1 | Out-Null } catch {}

    Write-LogSuccess "kind uninstalled"
    exit 0
}

Main
