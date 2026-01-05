# Uninstall script for pre-commit on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting pre-commit uninstallation on Windows..."

    try { pip uninstall pre-commit -y 2>&1 | Out-Null } catch {}
    try { choco uninstall pre-commit -y --no-progress 2>&1 | Out-Null } catch {}
    try { scoop uninstall pre-commit 2>&1 | Out-Null } catch {}

    Write-LogSuccess "pre-commit uninstalled"
    exit 0
}

Main
