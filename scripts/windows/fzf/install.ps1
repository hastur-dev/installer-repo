# Install script for fzf on Windows
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

# Install fzf using winget
function Install-FzfWithWinget {
    Write-LogInfo "Installing fzf via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget install --id junegunn.fzf --accept-source-agreements --accept-package-agreements --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "fzf installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install fzf via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install fzf using Chocolatey
function Install-FzfWithChocolatey {
    Write-LogInfo "Installing fzf via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install fzf -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "fzf installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install fzf via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed fzf
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-FzfInstallation {
    Write-LogInfo "Verifying fzf installation..."
    Update-PathEnvironment

    $fzfCommand = Get-Command fzf -ErrorAction SilentlyContinue

    if (-not $fzfCommand) {
        Write-LogError "fzf command not found after installation"
        return $false
    }

    try {
        $fzfVersion = & $fzfCommand.Source --version 2>&1

        if ([string]::IsNullOrEmpty($fzfVersion)) {
            Write-LogError "Could not retrieve fzf version"
            return $false
        }

        Write-LogSuccess "fzf verified: $fzfVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify fzf: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting fzf installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-FzfWithWinget
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
        $installed = Install-FzfWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install fzf with any available package manager"
        exit 1
    }

    if (-not (Test-FzfInstallation)) {
        Write-LogError "fzf installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
