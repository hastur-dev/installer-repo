# Install script for biome on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting biome installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install biome -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install biome 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        try {
            $release = Invoke-RestMethod -Uri "https://api.github.com/repos/biomejs/biome/releases/latest"
            $asset = $release.assets | Where-Object { $_.name -eq "biome-win32-x64.exe" } | Select-Object -First 1
            if ($asset) {
                Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "C:\Windows\System32\biome.exe"
                $installed = $true
            }
        } catch {
            # Fallback: try npm installation
            if (Get-Command npm -ErrorAction SilentlyContinue) {
                npm install -g @biomejs/biome 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) { $installed = $true }
            }
        }
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command biome -ErrorAction SilentlyContinue) {
        Write-LogSuccess "biome installed: $(biome --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install biome"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
exit 0
