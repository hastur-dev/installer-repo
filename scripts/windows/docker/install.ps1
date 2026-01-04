# Install script for Docker on Windows
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

# Install Docker using winget
function Install-DockerWithWinget {
    Write-LogInfo "Installing Docker Desktop via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget install --id Docker.DockerDesktop --accept-source-agreements --accept-package-agreements --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "Docker Desktop installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Docker Desktop via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install Docker using Chocolatey
function Install-DockerWithChocolatey {
    Write-LogInfo "Installing Docker Desktop via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install docker-desktop -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Docker Desktop installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Docker Desktop via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed docker
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-DockerInstallation {
    Write-LogInfo "Verifying Docker installation..."
    Update-PathEnvironment

    $dockerCommand = Get-Command docker -ErrorAction SilentlyContinue

    if (-not $dockerCommand) {
        Write-LogInfo "docker command not found - Docker Desktop may need to be started"
        Write-LogInfo "Please launch Docker Desktop from the Start menu"
        return $true
    }

    try {
        $dockerVersion = & docker --version 2>&1

        if ([string]::IsNullOrEmpty($dockerVersion)) {
            Write-LogError "Could not retrieve Docker version"
            return $false
        }

        Write-LogSuccess "Docker verified: $dockerVersion"
        return $true
    } catch {
        Write-LogInfo "Docker CLI not available yet - start Docker Desktop first"
        return $true
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Docker Desktop installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-DockerWithWinget
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
        $installed = Install-DockerWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install Docker Desktop with any available package manager"
        exit 1
    }

    Test-DockerInstallation | Out-Null

    Write-LogInfo "Note: A system restart may be required for Docker Desktop"
    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
