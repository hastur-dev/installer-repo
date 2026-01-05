# Install script for curlie on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting curlie installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install curlie -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install curlie 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/rs/curlie/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -like "*windows_amd64.tar.gz" } | Select-Object -First 1
        $tarball = "$env:TEMP\curlie.tar.gz"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tarball
        tar -xzf $tarball -C "$env:TEMP"
        Copy-Item "$env:TEMP\curlie.exe" -Destination "C:\Windows\System32\curlie.exe" -Force
        Remove-Item $tarball -Force
        $installed = $true
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command curlie -ErrorAction SilentlyContinue) {
        Write-LogSuccess "curlie installed: $(curlie --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install curlie"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
