# Uninstall script for ripgrep on Windows

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

# Check if ripgrep is installed
function Test-RipgrepInstalled {
    $rgCommand = Get-Command rg -ErrorAction SilentlyContinue
    if ($rgCommand) {
        return $true
    }
    return $false
}

# Uninstall ripgrep using winget
function Uninstall-RipgrepWithWinget {
    Write-LogInfo "Uninstalling ripgrep via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget uninstall --id BurntSushi.ripgrep.MSVC --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "not found") {
                Write-LogSuccess "ripgrep uninstalled successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ripgrep via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall ripgrep using Chocolatey
function Uninstall-RipgrepWithChocolatey {
    Write-LogInfo "Uninstalling ripgrep via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall ripgrep -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ripgrep uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ripgrep via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-RipgrepUninstalled {
    Write-LogInfo "Verifying ripgrep uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-RipgrepInstalled) {
        Write-LogError "ripgrep is still installed"
        return $false
    }
    Write-LogSuccess "ripgrep has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting ripgrep uninstallation on Windows..."

    if (-not (Test-RipgrepInstalled)) {
        Write-LogInfo "ripgrep is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "Trying winget..."
        $uninstalled = Uninstall-RipgrepWithWinget
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-RipgrepWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall ripgrep with any available package manager"
        exit 1
    }

    Test-RipgrepUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
