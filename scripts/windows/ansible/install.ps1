# Install script for ansible on Windows (automation tool)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }
function Write-LogWarn { param($Message) Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow }

function Main {
    Write-LogInfo "Starting ansible installation on Windows..."
    Write-LogWarn "Ansible has limited Windows support - consider using WSL"

    $installed = $false

    if (Get-Command pip -ErrorAction SilentlyContinue) {
        pip install ansible --quiet 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    if (-not $installed -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        choco install ansible -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Get-Command ansible -ErrorAction SilentlyContinue) {
        Write-LogSuccess "ansible installed: $(ansible --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install ansible"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
