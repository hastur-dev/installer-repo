# Uninstall script for ansible on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "uninstall.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting ansible uninstallation on Windows..."

    try { pip uninstall ansible -y 2>&1 | Out-Null } catch {}
    try { choco uninstall ansible -y --no-progress 2>&1 | Out-Null } catch {}

    Write-LogSuccess "ansible uninstalled"
    exit 0
}

Main
