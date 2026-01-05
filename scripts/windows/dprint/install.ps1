# Install script for dprint on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting dprint installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install dprint -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install dprint 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/dprint/dprint/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -like "*x86_64-pc-windows-msvc.zip" } | Select-Object -First 1
        $zip = "$env:TEMP\dprint.zip"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath "$env:TEMP\dprint" -Force
        $exe = Get-ChildItem -Path "$env:TEMP\dprint" -Recurse -Filter "dprint.exe" | Select-Object -First 1
        Copy-Item $exe.FullName -Destination "C:\Windows\System32\dprint.exe" -Force
        Remove-Item $zip -Force
        $installed = $true
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command dprint -ErrorAction SilentlyContinue) {
        Write-LogSuccess "dprint installed: $(dprint --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install dprint"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
exit 0
