# Install script for k9s on Windows (Kubernetes CLI dashboard)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting k9s installation on Windows..."

    $installed = $false

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id derailed.k9s --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    if (-not $installed -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        choco install k9s -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install k9s 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Get-Command k9s -ErrorAction SilentlyContinue) {
        Write-LogSuccess "k9s installed: $(k9s version --short 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install k9s"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
