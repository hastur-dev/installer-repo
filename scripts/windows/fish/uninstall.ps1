# Uninstall script for fish shell on Windows

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

# Check if Chocolatey is available
function Test-ChocolateyInstalled {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Check if MSYS2 fish is installed
function Test-FishInstalledMsys2 {
    $msys2Fish = "C:\msys64\usr\bin\fish.exe"
    if (Test-Path $msys2Fish) {
        return $true
    }
    return $false
}

# Check if fish is installed
function Test-FishInstalled {
    $fishCommand = Get-Command fish -ErrorAction SilentlyContinue
    if ($fishCommand) {
        return $true
    }
    return Test-FishInstalledMsys2
}

# Uninstall fish from MSYS2
function Uninstall-FishFromMsys2 {
    Write-LogInfo "Uninstalling fish from MSYS2..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $msys2Path = "C:\msys64\usr\bin\bash.exe"
            if (Test-Path $msys2Path) {
                & $msys2Path -lc "pacman -R --noconfirm fish" 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-LogSuccess "fish uninstalled successfully from MSYS2"
                    return $true
                }
            }
        } catch {
            Write-LogInfo "MSYS2 uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall fish from MSYS2 after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-FishUninstalled {
    Write-LogInfo "Verifying fish uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-FishInstalled) {
        Write-LogError "fish is still installed"
        return $false
    }
    Write-LogSuccess "fish has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting fish uninstallation on Windows..."

    if (-not (Test-FishInstalled)) {
        Write-LogInfo "fish is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    # Try MSYS2 uninstall
    if (Test-FishInstalledMsys2) {
        Write-LogInfo "Trying MSYS2..."
        $uninstalled = Uninstall-FishFromMsys2
    }

    if (-not $uninstalled) {
        Write-LogWarn "Could not automatically uninstall fish"
        Write-LogInfo "Manual uninstall options:"
        Write-LogInfo "  1. For MSYS2: Open MSYS2 terminal and run 'pacman -R fish'"
        Write-LogInfo "  2. For WSL: Run 'sudo apt remove fish' in your WSL distro"
        Write-LogInfo "  3. For Cygwin: Use Cygwin setup to remove fish package"
        exit 1
    }

    Test-FishUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
