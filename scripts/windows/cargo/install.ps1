# Install script for Rust toolchain (cargo) on Windows
# Supports winget (preferred) and Chocolatey as fallback

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
    return $false
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

# Install Rust using winget
function Install-RustWithWinget {
    Write-LogInfo "Installing Rust via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget install --id Rustlang.Rustup --accept-source-agreements --accept-package-agreements --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "Rust installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Rust via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install Rust using Chocolatey
function Install-RustWithChocolatey {
    Write-LogInfo "Installing Rust via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install rustup.install -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Rust installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Rust via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH environment
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    # Add cargo bin to path if it exists
    $cargoPath = "$env:USERPROFILE\.cargo\bin"
    if (Test-Path $cargoPath) {
        if ($env:Path -notlike "*$cargoPath*") {
            $env:Path = "$cargoPath;$env:Path"
        }
    }
}

# Verify installation
function Test-CargoInstallation {
    Write-LogInfo "Verifying Rust installation..."
    Update-PathEnvironment

    $cargoCommand = Get-Command cargo -ErrorAction SilentlyContinue

    if (-not $cargoCommand) {
        Write-LogError "cargo command not found after installation"
        return $false
    }

    try {
        $cargoVersion = & cargo --version 2>&1

        if ([string]::IsNullOrEmpty($cargoVersion)) {
            Write-LogError "Could not retrieve cargo version"
            return $false
        }

        Write-LogSuccess "cargo verified: $cargoVersion"

        $rustcCommand = Get-Command rustc -ErrorAction SilentlyContinue
        if ($rustcCommand) {
            $rustcVersion = & rustc --version 2>&1
            Write-LogSuccess "rustc verified: $rustcVersion"
        }

        $rustupCommand = Get-Command rustup -ErrorAction SilentlyContinue
        if ($rustupCommand) {
            $rustupVersion = & rustup --version 2>&1
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
    Write-LogInfo "Starting Rust toolchain installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-RustWithWinget
    }

    if (-not $installed) {
        Write-LogInfo "Trying Chocolatey..."
        if (-not (Test-ChocolateyInstalled)) {
            $chocoInstalled = Install-Chocolatey
            if (-not $chocoInstalled) {
                Write-LogError "Could not set up Chocolatey"
                exit 1
            }
        }
        $installed = Install-RustWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install Rust with any available package manager"
        exit 1
    }

    if (-not (Test-CargoInstallation)) {
        Write-LogError "Rust installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "Please restart your terminal to use cargo"
    exit 0
}

Main
