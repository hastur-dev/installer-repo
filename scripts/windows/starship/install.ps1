# Install script for Starship prompt on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install-windows.ps1"
$MAX_RETRY_ATTEMPTS = 3

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Test-WingetInstalled { try { $null = Get-Command winget -ErrorAction Stop; return $true } catch { return $false } }
function Test-ChocolateyInstalled { try { $null = Get-Command choco -ErrorAction Stop; return $true } catch { return $false } }

function Install-WithWinget {
    Write-LogInfo "Installing Starship via winget..."
    $result = winget install --id Starship.Starship --accept-source-agreements --accept-package-agreements --silent 2>&1
    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-LogSuccess "Starship installed via winget"
        return $true
    }
    return $false
}

function Install-WithChocolatey {
    Write-LogInfo "Installing Starship via Chocolatey..."
    choco install starship -y --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-LogSuccess "Starship installed via Chocolatey"
        return $true
    }
    return $false
}

function Main {
    Write-LogInfo "Starting Starship installation on Windows..."

    $installed = $false
    if (Test-WingetInstalled) { $installed = Install-WithWinget }
    if (-not $installed -and (Test-ChocolateyInstalled)) { $installed = Install-WithChocolatey }

    if (-not $installed) {
        Write-LogError "Failed to install Starship"
        exit 1
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "Add to PowerShell profile: Invoke-Expression (&starship init powershell)"
    exit 0
}

Main
