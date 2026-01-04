# Install script for ouch on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting ouch installation on Windows..."

    $installed = $false

    if (Get-Command cargo -ErrorAction SilentlyContinue) {
        cargo install ouch --locked 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            Write-LogSuccess "ouch installed via cargo"
        }
    }

    if (-not $installed) {
        Write-LogError "Failed to install ouch (requires cargo)"
        exit 1
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
