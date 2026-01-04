# Uninstall script for pnpm on Windows

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

function Write-LogWarn {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow
}

# Check if pnpm is installed
function Test-PnpmInstalled {
    $pnpmCommand = Get-Command pnpm -ErrorAction SilentlyContinue
    if ($pnpmCommand) {
        return $true
    }
    return $false
}

# Check if npm is installed
function Test-NpmInstalled {
    try {
        $null = Get-Command npm -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check if corepack is available
function Test-CorepackAvailable {
    try {
        $null = Get-Command corepack -ErrorAction Stop
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

# Uninstall pnpm via npm
function Uninstall-PnpmViaNpm {
    Write-LogInfo "Uninstalling pnpm via npm..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            npm uninstall -g pnpm 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "pnpm uninstalled successfully via npm"
                return $true
            }
        } catch {
            Write-LogInfo "npm uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Disable pnpm via corepack
function Disable-PnpmViaCorepack {
    Write-LogInfo "Disabling pnpm via corepack..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            corepack disable pnpm 2>&1 | Out-Null
            Write-LogSuccess "pnpm disabled via corepack"
            return $true
        } catch {
            Write-LogInfo "Corepack disable attempt $attempt failed: $_"
        }
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Uninstall pnpm via Chocolatey
function Uninstall-PnpmViaChocolatey {
    Write-LogInfo "Uninstalling pnpm via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall pnpm -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "pnpm uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Remove standalone installation
function Remove-StandalonePnpm {
    Write-LogInfo "Removing standalone pnpm installation..."

    $pnpmHome = "$env:LOCALAPPDATA\pnpm"
    if (Test-Path $pnpmHome) {
        Remove-Item -Recurse -Force $pnpmHome -ErrorAction SilentlyContinue
        Write-LogSuccess "Removed pnpm home directory: $pnpmHome"
    }

    $pnpmStore = "$env:LOCALAPPDATA\pnpm-store"
    if (Test-Path $pnpmStore) {
        Remove-Item -Recurse -Force $pnpmStore -ErrorAction SilentlyContinue
        Write-LogInfo "Removed pnpm store directory"
    }
}

# Verify uninstallation
function Test-PnpmUninstalled {
    Write-LogInfo "Verifying pnpm uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-PnpmInstalled) {
        Write-LogWarn "pnpm is still installed"
        return $false
    }
    Write-LogSuccess "pnpm has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting pnpm uninstallation on Windows..."

    if (-not (Test-PnpmInstalled)) {
        Write-LogInfo "pnpm is not installed, nothing to uninstall"
        exit 0
    }

    $pnpmVersion = & pnpm --version 2>&1
    Write-LogInfo "Current pnpm installation: $pnpmVersion"

    $uninstalled = $false

    # Try corepack disable
    if (Test-CorepackAvailable) {
        Disable-PnpmViaCorepack | Out-Null
    }

    # Try npm uninstall
    if (Test-NpmInstalled) {
        $uninstalled = Uninstall-PnpmViaNpm
    }

    # Try Chocolatey
    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        $uninstalled = Uninstall-PnpmViaChocolatey
    }

    # Remove standalone installation
    Remove-StandalonePnpm

    if (-not $uninstalled) {
        Write-LogWarn "Could not uninstall pnpm via package manager"
        Write-LogInfo "You may need to manually remove pnpm"
    }

    Test-PnpmUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
