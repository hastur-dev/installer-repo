# Install script for Rust on Windows
# Uses rustup for installation

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "install-windows.ps1"
$MAX_RETRY_ATTEMPTS = 3
$RETRY_DELAY_SECONDS = 2
$RUSTUP_INIT_URL = "https://win.rustup.rs/x86_64"

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

# Download rustup-init
function Get-RustupInit {
    Write-LogInfo "Downloading rustup-init..."

    $tempPath = "$env:TEMP\rustup-init.exe"

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            Invoke-WebRequest -Uri $RUSTUP_INIT_URL -OutFile $tempPath -UseBasicParsing
            if (Test-Path $tempPath) {
                Write-LogInfo "rustup-init downloaded successfully"
                return $tempPath
            }
        } catch {
            Write-LogInfo "Download attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to download rustup-init after $MAX_RETRY_ATTEMPTS attempts"
    return $null
}

# Install Rust using rustup
function Install-Rust {
    param([Parameter(Mandatory=$true)][string]$RustupPath)

    Write-LogInfo "Installing Rust via rustup..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            & $RustupPath -y 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Rust installed successfully"
                return $true
            }
        } catch {
            Write-LogInfo "Install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to install Rust after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $cargoPath = "$env:USERPROFILE\.cargo\bin"
    if ((Test-Path $cargoPath) -and ($env:Path -notlike "*$cargoPath*")) {
        $env:Path = "$cargoPath;$env:Path"
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-RustInstallation {
    Write-LogInfo "Verifying Rust installation..."
    Update-PathEnvironment

    $rustcCommand = Get-Command rustc -ErrorAction SilentlyContinue
    if (-not $rustcCommand) {
        Write-LogError "rustc command not found after installation"
        return $false
    }

    try {
        $rustcVersion = & rustc --version 2>&1
        if ([string]::IsNullOrEmpty($rustcVersion)) {
            Write-LogError "Could not retrieve Rust version"
            return $false
        }
        Write-LogSuccess "Rust verified: $rustcVersion"

        $cargoVersion = & cargo --version 2>&1
        if ($cargoVersion) {
            Write-LogSuccess "Cargo verified: $cargoVersion"
        }

        $rustupVersion = & rustup --version 2>&1
        if ($rustupVersion) {
            Write-LogSuccess "rustup verified: $rustupVersion"
        }

        return $true
    } catch {
        Write-LogError "Failed to verify Rust: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Rust installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    # Check if already installed
    Update-PathEnvironment
    $existingRustc = Get-Command rustc -ErrorAction SilentlyContinue
    if ($existingRustc) {
        Write-LogInfo "Rust is already installed, updating..."
        try {
            & rustup update 2>&1 | Out-Null
        } catch {
            Write-LogInfo "Update failed, continuing with verification"
        }
    } else {
        $rustupPath = Get-RustupInit
        if (-not $rustupPath) {
            Write-LogError "Failed to download rustup-init"
            exit 1
        }

        if (-not (Install-Rust -RustupPath $rustupPath)) {
            exit 1
        }

        # Clean up
        Remove-Item $rustupPath -ErrorAction SilentlyContinue
    }

    if (-not (Test-RustInstallation)) {
        Write-LogError "Rust installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "Note: You may need to restart your terminal for PATH changes to take effect"
    exit 0
}

Main
