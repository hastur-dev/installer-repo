# Uninstall script for nano on Windows

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

# Check if nano is installed
function Test-NanoInstalled {
    $nanoCommand = Get-Command nano -ErrorAction SilentlyContinue
    if ($nanoCommand) {
        return $true
    }
    return $false
}

# Uninstall nano using winget
function Uninstall-NanoWithWinget {
    Write-LogInfo "Uninstalling nano via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget uninstall --id GNU.Nano --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "not found") {
                Write-LogSuccess "nano uninstalled successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall nano via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall nano using Chocolatey
function Uninstall-NanoWithChocolatey {
    Write-LogInfo "Uninstalling nano via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall nano -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "nano uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall nano via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-NanoUninstalled {
    Write-LogInfo "Verifying nano uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-NanoInstalled) {
        Write-LogError "nano is still installed"
        return $false
    }
    Write-LogSuccess "nano has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting nano uninstallation on Windows..."

    if (-not (Test-NanoInstalled)) {
        Write-LogInfo "nano is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "Trying winget..."
        $uninstalled = Uninstall-NanoWithWinget
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-NanoWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall nano with any available package manager"
        exit 1
    }

    Test-NanoUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
