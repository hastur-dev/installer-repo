# Install script for Vim on Windows
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

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[INFO] ${SCRIPT_NAME}: $Message"
}

function Write-LogError {
    param([Parameter(Mandatory=$true)][string]$Message)

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red
}

function Write-LogSuccess {
    param([Parameter(Mandatory=$true)][string]$Message)

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green
}

# Check if running on Windows
function Test-WindowsEnvironment {
    Write-LogInfo "Verifying Windows environment..."

    # Postcondition: must be Windows
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

        # Refresh environment
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Postcondition: verify installation
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

# Install Vim using winget
function Install-VimWithWinget {
    Write-LogInfo "Installing Vim via winget..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++

        try {
            # Accept source agreements and install
            $result = winget install --id vim.vim --accept-source-agreements --accept-package-agreements --silent 2>&1

            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "Vim installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }

        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to install Vim via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install Vim using Chocolatey
function Install-VimWithChocolatey {
    Write-LogInfo "Installing Vim via Chocolatey..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++

        try {
            choco install vim -y --no-progress 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Vim installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }

        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to install Vim via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed vim
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."

    # Common Vim installation paths
    $vimPaths = @(
        "$env:ProgramFiles\Vim\vim*",
        "$env:ProgramFiles(x86)\Vim\vim*",
        "$env:LOCALAPPDATA\Programs\Vim\vim*",
        "C:\tools\vim\vim*"
    )

    $pathsToAdd = @()

    foreach ($pattern in $vimPaths) {
        $matches = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            if (Test-Path $match.FullName) {
                $pathsToAdd += $match.FullName
            }
        }
    }

    if ($pathsToAdd.Count -gt 0) {
        $env:Path = ($pathsToAdd -join ";") + ";" + $env:Path
    }

    # Also refresh from registry
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-VimInstallation {
    Write-LogInfo "Verifying Vim installation..."

    Update-PathEnvironment

    # Try to find vim
    $vimCommand = Get-Command vim -ErrorAction SilentlyContinue
    if (-not $vimCommand) {
        $vimCommand = Get-Command vim.exe -ErrorAction SilentlyContinue
    }

    if (-not $vimCommand) {
        Write-LogError "Vim command not found after installation"
        return $false
    }

    # Get version
    try {
        $vimVersion = & $vimCommand.Source --version 2>&1 | Select-Object -First 1

        # Postcondition: version should not be empty
        if ([string]::IsNullOrEmpty($vimVersion)) {
            Write-LogError "Could not retrieve Vim version"
            return $false
        }

        Write-LogSuccess "Vim verified: $vimVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify Vim: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Vim installation on Windows..."

    # Verify Windows environment
    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    # Try winget first (preferred)
    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-VimWithWinget
    }

    # Fallback to Chocolatey
    if (-not $installed) {
        Write-LogInfo "Trying Chocolatey..."

        if (-not (Test-ChocolateyInstalled)) {
            $chocoInstalled = Install-Chocolatey
            if (-not $chocoInstalled) {
                Write-LogError "Could not set up Chocolatey"
                exit 1
            }
        }

        $installed = Install-VimWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install Vim with any available package manager"
        exit 1
    }

    # Verify installation
    if (-not (Test-VimInstallation)) {
        Write-LogError "Vim installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
