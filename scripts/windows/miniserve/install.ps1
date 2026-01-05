# Install script for miniserve on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting miniserve installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install miniserve -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install miniserve 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/svenstaro/miniserve/releases/latest"
        $version = $release.tag_name -replace '^v', ''
        $asset = $release.assets | Where-Object { $_.name -like "*x86_64-pc-windows-msvc.exe" } | Select-Object -First 1
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "C:\Windows\System32\miniserve.exe"
        $installed = $true
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command miniserve -ErrorAction SilentlyContinue) {
        Write-LogSuccess "miniserve installed: $(miniserve --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install miniserve"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
