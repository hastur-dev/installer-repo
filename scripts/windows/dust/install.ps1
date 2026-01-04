# Install script for dust on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting dust installation on Windows..."

    $installed = $false

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        $result = winget install --id bootandy.dust --accept-source-agreements --accept-package-agreements --silent 2>&1
        if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
            $installed = $true
            Write-LogSuccess "dust installed via winget"
        }
    }

    if (-not $installed -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        choco install dust -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $installed = $true
            Write-LogSuccess "dust installed via Chocolatey"
        }
    }

    if (-not $installed) {
        Write-LogError "Failed to install dust"
        exit 1
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
