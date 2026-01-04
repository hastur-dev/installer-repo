# Uninstall script for Redis on Windows

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

# Check if Redis is installed
function Test-RedisInstalled {
    $redisCommand = Get-Command redis-server -ErrorAction SilentlyContinue
    if ($redisCommand) {
        return $true
    }
    return $false
}

# Stop Redis if running
function Stop-RedisService {
    Write-LogInfo "Stopping Redis if running..."
    try {
        $redisProcess = Get-Process -Name "redis-server" -ErrorAction SilentlyContinue
        if ($redisProcess) {
            Stop-Process -Name "redis-server" -Force
            Write-LogInfo "Redis server stopped"
        }
    } catch {
        Write-LogInfo "Could not stop Redis process: $_"
    }
}

# Uninstall Redis using Chocolatey
function Uninstall-RedisWithChocolatey {
    Write-LogInfo "Uninstalling Redis via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall redis-64 -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Redis uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Redis via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-RedisUninstalled {
    Write-LogInfo "Verifying Redis uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-RedisInstalled) {
        Write-LogError "Redis is still installed"
        return $false
    }
    Write-LogSuccess "Redis has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Redis uninstallation on Windows..."

    if (-not (Test-RedisInstalled)) {
        Write-LogInfo "Redis is not installed, nothing to uninstall"
        exit 0
    }

    try {
        $redisVersion = redis-server --version 2>&1
        Write-LogInfo "Current Redis installation: $redisVersion"
    } catch {
        Write-LogInfo "Could not determine Redis version"
    }

    Stop-RedisService

    $uninstalled = $false

    if (Test-ChocolateyInstalled) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-RedisWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall Redis"
        Write-LogInfo "You may need to uninstall Redis manually"
        exit 1
    }

    Test-RedisUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
