# Install script for poetry on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting poetry installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install poetry -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install poetry 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command poetry -ErrorAction SilentlyContinue) {
        Write-LogSuccess "poetry installed: $(poetry --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install poetry"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
