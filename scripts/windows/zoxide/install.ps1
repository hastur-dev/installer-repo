# Install script for zoxide on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SCRIPT_NAME = "install.ps1"
$MAX_RETRY_ATTEMPTS = 3

function Write-LogInfo { param($Message) Write-Host "[INFO] ${SCRIPT_NAME}: $Message" }
function Write-LogError { param($Message) Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red }
function Write-LogSuccess { param($Message) Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green }

function Test-WingetInstalled { try { $null = Get-Command winget -ErrorAction Stop; return $true } catch { return $false } }
function Test-ChocolateyInstalled { try { $null = Get-Command choco -ErrorAction Stop; return $true } catch { return $false } }

function Install-WithWinget {
    Write-LogInfo "Installing zoxide via winget..."
    $result = winget install --id ajeetdsouza.zoxide --accept-source-agreements --accept-package-agreements --silent 2>&1
    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-LogSuccess "zoxide installed via winget"
        return $true
    }
    return $false
}

function Install-WithChocolatey {
    Write-LogInfo "Installing zoxide via Chocolatey..."
    choco install zoxide -y --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-LogSuccess "zoxide installed via Chocolatey"
        return $true
    }
    return $false
}

function Main {
    Write-LogInfo "Starting zoxide installation on Windows..."

    $installed = $false
    if (Test-WingetInstalled) { $installed = Install-WithWinget }
    if (-not $installed -and (Test-ChocolateyInstalled)) { $installed = Install-WithChocolatey }

    if (-not $installed) {
        Write-LogError "Failed to install zoxide"
        exit 1
    }

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "Add to PowerShell profile: Invoke-Expression (& { (zoxide init powershell | Out-String) })"
    exit 0
}

Main
