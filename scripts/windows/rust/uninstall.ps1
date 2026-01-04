# Uninstall script for Rust on Windows
# Uses rustup for uninstallation

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

# Refresh PATH
function Update-PathEnvironment {
    $cargoPath = "$env:USERPROFILE\.cargo\bin"
    if ((Test-Path $cargoPath) -and ($env:Path -notlike "*$cargoPath*")) {
        $env:Path = "$cargoPath;$env:Path"
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Check if Rust is installed
function Test-RustInstalled {
    Update-PathEnvironment
    $rustcCommand = Get-Command rustc -ErrorAction SilentlyContinue
    $rustupCommand = Get-Command rustup -ErrorAction SilentlyContinue
    return ($null -ne $rustcCommand) -or ($null -ne $rustupCommand)
}

# Uninstall Rust using rustup
function Uninstall-Rust {
    Write-LogInfo "Uninstalling Rust via rustup..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            & rustup self uninstall -y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Rust uninstalled successfully"
                return $true
            }
        } catch {
            Write-LogInfo "Uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to uninstall Rust after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-RustUninstalled {
    Write-LogInfo "Verifying Rust uninstallation..."

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $rustcCommand = Get-Command rustc -ErrorAction SilentlyContinue
    if ($rustcCommand) {
        Write-LogError "rustc is still installed"
        return $false
    }

    $cargoDir = "$env:USERPROFILE\.cargo"
    if (Test-Path $cargoDir) {
        Write-LogInfo "Note: $cargoDir still exists, you may want to remove it manually"
    }

    $rustupDir = "$env:USERPROFILE\.rustup"
    if (Test-Path $rustupDir) {
        Write-LogInfo "Note: $rustupDir still exists, you may want to remove it manually"
    }

    Write-LogSuccess "Rust has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Rust uninstallation on Windows..."

    if (-not (Test-RustInstalled)) {
        Write-LogInfo "Rust is not installed, nothing to uninstall"
        exit 0
    }

    if (-not (Uninstall-Rust)) {
        exit 1
    }

    Test-RustUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
