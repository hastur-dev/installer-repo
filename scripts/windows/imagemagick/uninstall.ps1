# Uninstall script for ImageMagick on Windows

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

# Check if ImageMagick is installed
function Test-ImageMagickInstalled {
    $magickCommand = Get-Command magick -ErrorAction SilentlyContinue
    if ($magickCommand) {
        return $true
    }
    return $false
}

# Uninstall ImageMagick using winget
function Uninstall-ImageMagickWithWinget {
    Write-LogInfo "Uninstalling ImageMagick via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget uninstall --id ImageMagick.ImageMagick --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "not found") {
                Write-LogSuccess "ImageMagick uninstalled successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ImageMagick via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall ImageMagick using Chocolatey
function Uninstall-ImageMagickWithChocolatey {
    Write-LogInfo "Uninstalling ImageMagick via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall imagemagick -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ImageMagick uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ImageMagick via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-ImageMagickUninstalled {
    Write-LogInfo "Verifying ImageMagick uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-ImageMagickInstalled) {
        Write-LogError "ImageMagick is still installed"
        return $false
    }
    Write-LogSuccess "ImageMagick has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting ImageMagick uninstallation on Windows..."

    if (-not (Test-ImageMagickInstalled)) {
        Write-LogInfo "ImageMagick is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "Trying winget..."
        $uninstalled = Uninstall-ImageMagickWithWinget
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-ImageMagickWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall ImageMagick with any available package manager"
        exit 1
    }

    Test-ImageMagickUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
