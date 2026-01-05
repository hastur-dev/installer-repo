# Install script for minikube on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting minikube installation on Windows..."
    $installed = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Kubernetes.minikube --accept-source-agreements --accept-package-agreements --silent 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command choco -ErrorAction SilentlyContinue)) {
        choco install minikube -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command minikube -ErrorAction SilentlyContinue) {
        Write-LogSuccess "minikube installed: $(minikube version --short 2>&1)"
    } else {
        Write-LogError "Failed to install minikube"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
