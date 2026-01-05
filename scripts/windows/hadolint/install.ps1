# Install script for hadolint on Windows (Dockerfile linter)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting hadolint installation on Windows..."

    $installed = $false

    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install hadolint -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install hadolint 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Get-Command hadolint -ErrorAction SilentlyContinue) {
        Write-LogSuccess "hadolint installed: $(hadolint --version 2>&1)"
    } else {
        Write-LogError "Failed to install hadolint"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
