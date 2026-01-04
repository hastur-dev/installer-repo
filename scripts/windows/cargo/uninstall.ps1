# Uninstall script for Rust toolchain (cargo) on Windows

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

# Check if rustup is installed
function Test-RustupInstalled {
    $rustupCommand = Get-Command rustup -ErrorAction SilentlyContinue
    if ($rustupCommand) {
        return $true
    }
    # Check in default location
    $rustupPath = "$env:USERPROFILE\.cargo\bin\rustup.exe"
    if (Test-Path $rustupPath) {
        return $true
    }
    return $false
}

# Check if cargo is installed
function Test-CargoInstalled {
    $cargoCommand = Get-Command cargo -ErrorAction SilentlyContinue
    if ($cargoCommand) {
        return $true
    }
    return $false
}

# Uninstall Rust using rustup
function Uninstall-RustWithRustup {
    Write-LogInfo "Uninstalling Rust via rustup..."
    $attempt = 0

    # Add cargo bin to path if not already
    $cargoPath = "$env:USERPROFILE\.cargo\bin"
    if (Test-Path $cargoPath) {
        if ($env:Path -notlike "*$cargoPath*") {
            $env:Path = "$cargoPath;$env:Path"
        }
    }

    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = & rustup self uninstall -y 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Rust uninstalled successfully via rustup"
                return $true
            }
        } catch {
            Write-LogInfo "rustup uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Rust via rustup after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall Rust using winget
function Uninstall-RustWithWinget {
    Write-LogInfo "Uninstalling Rust via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget uninstall --id Rustlang.Rustup --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "not found") {
                Write-LogSuccess "Rust uninstalled successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Rust via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall Rust using Chocolatey
function Uninstall-RustWithChocolatey {
    Write-LogInfo "Uninstalling Rust via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall rustup.install -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Rust uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Rust via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-RustUninstalled {
    Write-LogInfo "Verifying Rust uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-CargoInstalled) {
        Write-LogWarn "cargo is still installed"
        return $false
    }

    $cargoDir = "$env:USERPROFILE\.cargo"
    if (Test-Path $cargoDir) {
        Write-LogWarn ".cargo directory still exists at $cargoDir"
        Write-LogInfo "You may want to remove it manually"
    }

    $rustupDir = "$env:USERPROFILE\.rustup"
    if (Test-Path $rustupDir) {
        Write-LogWarn ".rustup directory still exists at $rustupDir"
        Write-LogInfo "You may want to remove it manually"
    }

    Write-LogSuccess "Rust toolchain has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Rust toolchain uninstallation on Windows..."

    if (-not (Test-RustupInstalled) -and -not (Test-CargoInstalled)) {
        Write-LogInfo "Rust is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    # Try rustup first (preferred method)
    if (Test-RustupInstalled) {
        $uninstalled = Uninstall-RustWithRustup
    }

    if (-not $uninstalled -and (Test-WingetInstalled)) {
        Write-LogInfo "Trying winget..."
        $uninstalled = Uninstall-RustWithWinget
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-RustWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall Rust with any available method"
        exit 1
    }

    Test-RustUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
