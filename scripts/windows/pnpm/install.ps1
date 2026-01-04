# Install script for pnpm on Windows
# Uses npm, corepack, or package managers

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

# Check if Node.js is installed
function Test-NodeInstalled {
    try {
        $null = Get-Command node -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
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

# Install pnpm via corepack
function Install-PnpmViaCorepack {
    Write-LogInfo "Installing pnpm via corepack..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            corepack enable 2>&1 | Out-Null
            corepack prepare pnpm@latest --activate 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "pnpm installed successfully via corepack"
                return $true
            }
        } catch {
            Write-LogInfo "Corepack install attempt $attempt failed: $_"
        }
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Install pnpm via npm
function Install-PnpmViaNpm {
    Write-LogInfo "Installing pnpm via npm..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            npm install -g pnpm 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "pnpm installed successfully via npm"
                return $true
            }
        } catch {
            Write-LogInfo "npm install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install pnpm via npm after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install pnpm via Chocolatey
function Install-PnpmViaChocolatey {
    Write-LogInfo "Installing pnpm via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install pnpm -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "pnpm installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Install pnpm via standalone script
function Install-PnpmViaScript {
    Write-LogInfo "Installing pnpm via standalone script..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            Invoke-WebRequest https://get.pnpm.io/install.ps1 -UseBasicParsing | Invoke-Expression
            Write-LogSuccess "pnpm installed successfully via standalone script"
            return $true
        } catch {
            Write-LogInfo "Script install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Refresh PATH environment
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    # Add pnpm home if it exists
    $pnpmHome = "$env:LOCALAPPDATA\pnpm"
    if (Test-Path $pnpmHome) {
        if ($env:Path -notlike "*$pnpmHome*") {
            $env:Path = "$pnpmHome;$env:Path"
        }
    }
}

# Verify installation
function Test-PnpmInstallation {
    Write-LogInfo "Verifying pnpm installation..."
    Update-PathEnvironment

    $pnpmCommand = Get-Command pnpm -ErrorAction SilentlyContinue

    if (-not $pnpmCommand) {
        Write-LogError "pnpm command not found after installation"
        return $false
    }

    try {
        $pnpmVersion = & pnpm --version 2>&1

        if ([string]::IsNullOrEmpty($pnpmVersion)) {
            Write-LogError "Could not retrieve pnpm version"
            return $false
        }

        Write-LogSuccess "pnpm verified: $pnpmVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify pnpm: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting pnpm installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    if (-not (Test-NodeInstalled)) {
        Write-LogError "Node.js is not installed. Please install Node.js first."
        exit 1
    }

    $nodeVersion = & node --version 2>&1
    Write-LogInfo "Node.js version: $nodeVersion"

    $installed = $false

    # Try corepack first
    if (Test-CorepackAvailable) {
        $installed = Install-PnpmViaCorepack
    }

    # Try npm
    if (-not $installed -and (Test-NpmInstalled)) {
        $installed = Install-PnpmViaNpm
    }

    # Try standalone script
    if (-not $installed) {
        $installed = Install-PnpmViaScript
    }

    # Try Chocolatey
    if (-not $installed -and (Test-ChocolateyInstalled)) {
        $installed = Install-PnpmViaChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install pnpm with any available method"
        exit 1
    }

    if (-not (Test-PnpmInstallation)) {
        Write-LogError "pnpm installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
