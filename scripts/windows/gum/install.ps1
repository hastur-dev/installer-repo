# Install script for gum on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting gum installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install gum -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install gum 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/charmbracelet/gum/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -like "*Windows_x86_64.zip" } | Select-Object -First 1
        $zip = "$env:TEMP\gum.zip"
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
        Expand-Archive -Path $zip -DestinationPath "$env:TEMP\gum" -Force
        $exe = Get-ChildItem -Path "$env:TEMP\gum" -Recurse -Filter "gum.exe" | Select-Object -First 1
        Copy-Item $exe.FullName -Destination "C:\Windows\System32\gum.exe" -Force
        Remove-Item $zip -Force
        $installed = $true
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command gum -ErrorAction SilentlyContinue) {
        Write-LogSuccess "gum installed: $(gum --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install gum"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
exit 0
