# Install script for fish shell on Windows
# Note: fish is primarily designed for Unix systems
# On Windows, consider using fish through WSL or alternative shells

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

# Check if MSYS2 is available
function Test-Msys2Installed {
    $msys2Paths = @(
        "C:\msys64\usr\bin\fish.exe",
        "C:\msys32\usr\bin\fish.exe"
    )
    foreach ($path in $msys2Paths) {
        if (Test-Path $path) {
            return $true
        }
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

# Install fish using MSYS2 via Chocolatey
function Install-FishWithChocolatey {
    Write-LogInfo "Installing fish via Chocolatey (MSYS2)..."
    Write-LogWarn "This will install MSYS2 if not present, which provides fish for Windows"

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            # First ensure MSYS2 is installed
            choco install msys2 -y --no-progress 2>&1 | Out-Null

            # Then install fish in MSYS2
            $msys2Path = "C:\msys64\usr\bin\bash.exe"
            if (Test-Path $msys2Path) {
                & $msys2Path -lc "pacman -S --noconfirm fish" 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Write-LogSuccess "fish installed successfully via MSYS2"
                    return $true
                }
            }
        } catch {
            Write-LogInfo "Chocolatey/MSYS2 install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install fish via Chocolatey/MSYS2 after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed fish
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    # Add MSYS2 paths
    $msys2Paths = @("C:\msys64\usr\bin", "C:\msys32\usr\bin")
    foreach ($path in $msys2Paths) {
        if ((Test-Path $path) -and ($env:Path -notlike "*$path*")) {
            $env:Path = "$path;$env:Path"
        }
    }
}

# Verify installation
function Test-FishInstallation {
    Write-LogInfo "Verifying fish installation..."
    Update-PathEnvironment

    $fishCommand = Get-Command fish -ErrorAction SilentlyContinue

    if (-not $fishCommand) {
        # Check MSYS2 location directly
        $msys2Fish = "C:\msys64\usr\bin\fish.exe"
        if (Test-Path $msys2Fish) {
            Write-LogSuccess "fish found at: $msys2Fish"
            Write-LogInfo "Add C:\msys64\usr\bin to your PATH to use fish globally"
            return $true
        }
        Write-LogError "fish command not found after installation"
        return $false
    }

    try {
        $fishVersion = & $fishCommand.Source --version 2>&1

        if ([string]::IsNullOrEmpty($fishVersion)) {
            Write-LogError "Could not retrieve fish version"
            return $false
        }

        Write-LogSuccess "fish verified: $fishVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify fish: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting fish installation on Windows..."
    Write-LogWarn "Note: fish is primarily designed for Unix-like systems (Linux/macOS)"
    Write-LogWarn "On Windows, fish runs best through MSYS2 or WSL"
    Write-LogInfo "Consider using PowerShell, Nushell, or WSL for native Windows experience"

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    # Check if already installed via MSYS2
    if (Test-Msys2Installed) {
        Write-LogInfo "fish appears to be already installed via MSYS2"
        $installed = $true
    }

    if (-not $installed) {
        Write-LogInfo "Trying Chocolatey with MSYS2..."
        if (-not (Test-ChocolateyInstalled)) {
            $chocoInstalled = Install-Chocolatey
            if (-not $chocoInstalled) {
                Write-LogError "Could not set up Chocolatey"
                exit 1
            }
        }
        $installed = Install-FishWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install fish"
        Write-LogInfo "Alternative options:"
        Write-LogInfo "  1. Use WSL: wsl --install, then install fish in your Linux distro"
        Write-LogInfo "  2. Install MSYS2 manually: https://www.msys2.org/"
        Write-LogInfo "  3. Use Git Bash or Cygwin with fish"
        exit 1
    }

    if (-not (Test-FishInstallation)) {
        Write-LogError "fish installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "To use fish, run it from MSYS2 terminal or add C:\msys64\usr\bin to PATH"
    exit 0
}

Main
