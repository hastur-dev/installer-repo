# Install script for mdbook on Windows
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$SCRIPT_NAME = "install.ps1"
function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Main {
    Write-LogInfo "Starting mdbook installation on Windows..."
    $installed = $false
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        choco install mdbook -y --no-progress 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed -and (Get-Command scoop -ErrorAction SilentlyContinue)) {
        scoop install mdbook 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { $installed = $true }
    }
    if (-not $installed) {
        $release = Invoke-RestMethod -Uri "https://api.github.com/repos/rust-lang/mdBook/releases/latest"
        $asset = $release.assets | Where-Object { $_.name -like "*x86_64-pc-windows-msvc.zip" } | Select-Object -First 1
        if ($asset) {
            $zip = "$env:TEMP\mdbook.zip"
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zip
            Expand-Archive -Path $zip -DestinationPath "$env:TEMP\mdbook" -Force
            $exe = Get-ChildItem -Path "$env:TEMP\mdbook" -Recurse -Filter "mdbook.exe" | Select-Object -First 1
            Copy-Item $exe.FullName -Destination "C:\Windows\System32\mdbook.exe" -Force
            Remove-Item $zip -Force
            $installed = $true
        }
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    if (Get-Command mdbook -ErrorAction SilentlyContinue) {
        Write-LogSuccess "mdbook installed: $(mdbook --version 2>&1 | Select-Object -First 1)"
    } else {
        Write-LogError "Failed to install mdbook"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
}
Main
exit 0
