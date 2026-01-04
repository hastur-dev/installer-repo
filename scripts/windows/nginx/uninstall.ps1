# Uninstall script for nginx on Windows

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "uninstall-windows.ps1"
$MAX_RETRY_ATTEMPTS = 3
$RETRY_DELAY_SECONDS = 2

# Logging functions
function Write-LogInfo {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[INFO] ${SCRIPT_NAME}: $Message"
}

function Write-LogError {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red
}

function Write-LogSuccess {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green
}

# Check if Chocolatey is available
function Test-ChocolateyInstalled {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check if nginx is installed
function Test-NginxInstalled {
    $nginxCommand = Get-Command nginx -ErrorAction SilentlyContinue
    if ($nginxCommand) {
        return $true
    }
    return $false
}

# Stop nginx if running
function Stop-NginxService {
    Write-LogInfo "Stopping nginx if running..."
    try {
        $nginxProcess = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
        if ($nginxProcess) {
            # Try graceful shutdown first
            & nginx -s stop 2>&1 | Out-Null
            Start-Sleep -Seconds 2
            # Force stop if still running
            $nginxProcess = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
            if ($nginxProcess) {
                Stop-Process -Name "nginx" -Force
            }
            Write-LogInfo "nginx stopped"
        }
    } catch {
        Write-LogInfo "Could not stop nginx process: $_"
    }
}

# Uninstall nginx using Chocolatey
function Uninstall-NginxWithChocolatey {
    Write-LogInfo "Uninstalling nginx via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall nginx -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "nginx uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall nginx via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-NginxUninstalled {
    Write-LogInfo "Verifying nginx uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-NginxInstalled) {
        Write-LogError "nginx is still installed"
        return $false
    }
    Write-LogSuccess "nginx has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting nginx uninstallation on Windows..."

    if (-not (Test-NginxInstalled)) {
        Write-LogInfo "nginx is not installed, nothing to uninstall"
        exit 0
    }

    try {
        $nginxVersion = nginx -v 2>&1
        Write-LogInfo "Current nginx installation: $nginxVersion"
    } catch {
        Write-LogInfo "Could not determine nginx version"
    }

    Stop-NginxService

    $uninstalled = $false

    if (Test-ChocolateyInstalled) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-NginxWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall nginx"
        Write-LogInfo "You may need to uninstall nginx manually"
        exit 1
    }

    Test-NginxUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
