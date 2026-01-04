# Install script for nginx on Windows
# Supports Chocolatey

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

# Install nginx using Chocolatey
function Install-NginxWithChocolatey {
    Write-LogInfo "Installing nginx via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install nginx -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "nginx installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install nginx via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed nginx
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $nginxPaths = @(
        "$env:ChocolateyInstall\lib\nginx\tools\nginx*",
        "$env:ProgramFiles\nginx",
        "${env:ProgramFiles(x86)}\nginx"
    )
    foreach ($pattern in $nginxPaths) {
        $matches = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            if ($env:Path -notlike "*$($match.FullName)*") {
                $env:Path = "$($match.FullName);$env:Path"
            }
        }
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-NginxInstallation {
    Write-LogInfo "Verifying nginx installation..."
    Update-PathEnvironment

    $nginxCommand = Get-Command nginx -ErrorAction SilentlyContinue

    if (-not $nginxCommand) {
        Write-LogError "nginx command not found after installation"
        return $false
    }

    try {
        $nginxVersion = & nginx -v 2>&1

        if ([string]::IsNullOrEmpty($nginxVersion)) {
            Write-LogError "Could not retrieve nginx version"
            return $false
        }

        Write-LogSuccess "nginx verified: $nginxVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify nginx: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting nginx installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    # Use Chocolatey for nginx
    Write-LogInfo "Using Chocolatey for nginx installation..."
    if (-not (Test-ChocolateyInstalled)) {
        $chocoInstalled = Install-Chocolatey
        if (-not $chocoInstalled) {
            Write-LogError "Could not set up Chocolatey"
            exit 1
        }
    }
    $installed = Install-NginxWithChocolatey

    if (-not $installed) {
        Write-LogError "Failed to install nginx"
        exit 1
    }

    if (-not (Test-NginxInstallation)) {
        Write-LogError "nginx installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    Write-LogInfo "To start nginx: nginx"
    Write-LogInfo "To stop nginx: nginx -s stop"
    exit 0
}

Main
