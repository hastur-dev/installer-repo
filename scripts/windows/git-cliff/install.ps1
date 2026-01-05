# Install script for git-cliff on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting git-cliff installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install git-cliff -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install git-cliff 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/orhun/git-cliff/releases/latest"
        $version = $release.tag_name -replace '^v', ''
        $asset = $release.assets | Where-Object { $_.name -like "*x86_64-pc-windows-msvc.zip" } | Select-Object -First 1
        $zip = "$env:TEMP\git-cliff.zip"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath "$env:TEMP\git-cliff" -Force
        $exe = Get-ChildItem -Path "$env:TEMP\git-cliff" -Recurse -Filter "git-cliff.exe" | Select-Object -First 1
        Copy-Item $exe.FullName -Destination "C:\Windows\System32\git-cliff.exe" -Force
        Remove-Item $zip -Force
        $installed = $true
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command git-cliff -ErrorAction SilentlyContinue) {
        Write-LogSuccess "git-cliff installed: $(git-cliff --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install git-cliff"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
exit 0
