# Install script for Redis on Windows
# Supports winget (preferred) and Chocolatey as fallback

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "install-windows.ps1"
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

function Write-LogWarn {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow
}

# Check if running on Windows
function Test-WindowsEnvironment {
    Write-LogInfo "Verifying Windows environment..."
    if (-not $IsWindows -and $env:OS -ne "Windows_NT") {
        Write-LogError "This script requires Windows"
        return $false
    }
    Write-LogInfo "Confirmed Windows environment"
    return $true
}

# Check if winget is available
function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
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

# Install Chocolatey if needed
function Install-Chocolatey {
    Write-LogInfo "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        $installScript = (New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')
        Invoke-Expression $installScript
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        if (-not (Test-ChocolateyInstalled)) {
            Write-LogError "Chocolatey installation verification failed"
            return $false
        }
        Write-LogSuccess "Chocolatey installed successfully"
        return $true
    } catch {
        Write-LogError "Failed to install Chocolatey: $_"
        return $false
    }
}

# Install Redis using Chocolatey (winget doesn't have official Redis)
function Install-RedisWithChocolatey {
    Write-LogInfo "Installing Redis via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install redis-64 -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Redis installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Redis via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed redis
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $redisPaths = @(
        "$env:ProgramFiles\Redis",
        "${env:ProgramFiles(x86)}\Redis",
        "$env:ChocolateyInstall\lib\redis-64\tools"
    )
    foreach ($path in $redisPaths) {
        if ((Test-Path $path) -and ($env:Path -notlike "*$path*")) {
            $env:Path = "$path;$env:Path"
        }
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-RedisInstallation {
    Write-LogInfo "Verifying Redis installation..."
    Update-PathEnvironment

    $redisCommand = Get-Command redis-server -ErrorAction SilentlyContinue

    if (-not $redisCommand) {
        Write-LogError "Redis command not found after installation"
        return $false
    }

    try {
        $redisVersion = & redis-server --version 2>&1

        if ([string]::IsNullOrEmpty($redisVersion)) {
            Write-LogError "Could not retrieve Redis version"
            return $false
        }

        Write-LogSuccess "Redis verified: $redisVersion"

        $redisCli = Get-Command redis-cli -ErrorAction SilentlyContinue
        if ($redisCli) {
            Write-LogSuccess "redis-cli is also available"
        }

        return $true
    } catch {
        Write-LogError "Failed to verify Redis: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Redis installation on Windows..."
    Write-LogWarn "Note: Redis is primarily designed for Linux. Windows support is via community ports."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    # Redis doesn't have an official winget package, use Chocolatey
    Write-LogInfo "Using Chocolatey for Redis installation..."
    if (-not (Test-ChocolateyInstalled)) {
        $chocoInstalled = Install-Chocolatey
        if (-not $chocoInstalled) {
            Write-LogError "Could not set up Chocolatey"
            exit 1
        }
    }
    $installed = Install-RedisWithChocolatey

    if (-not $installed) {
        Write-LogError "Failed to install Redis"
        Write-LogInfo "Alternative: Consider using Docker or WSL for Redis on Windows"
        exit 1
    }

    if (-not (Test-RedisInstallation)) {
        Write-LogError "Redis installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "Redis is listening on localhost:6379 by default"
    Write-LogInfo "To start Redis: redis-server"
    exit 0
}

Main
