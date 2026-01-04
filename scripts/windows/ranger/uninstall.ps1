# Uninstall script for ranger on Windows

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

# Check if Python is available
function Test-PythonInstalled {
    try {
        $null = Get-Command python -ErrorAction Stop
        return $true
    } catch {
        try {
            $null = Get-Command python3 -ErrorAction Stop
            return $true
        } catch {
            return $false
        }
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

# Check if ranger is installed
function Test-RangerInstalled {
    $rangerCommand = Get-Command ranger -ErrorAction SilentlyContinue
    if ($rangerCommand) {
        return $true
    }
    return $false
}

# Uninstall ranger using pip
function Uninstall-RangerWithPip {
    Write-LogInfo "Uninstalling ranger via pip..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $pythonCmd = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
            $result = & $pythonCmd -m pip uninstall ranger-fm -y 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ranger uninstalled successfully via pip"
                return $true
            }
        } catch {
            Write-LogInfo "Pip uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ranger via pip after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall ranger using Chocolatey
function Uninstall-RangerWithChocolatey {
    Write-LogInfo "Uninstalling ranger via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall ranger -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ranger uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall ranger via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-RangerUninstalled {
    Write-LogInfo "Verifying ranger uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-RangerInstalled) {
        Write-LogError "ranger is still installed"
        return $false
    }
    Write-LogSuccess "ranger has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting ranger uninstallation on Windows..."

    if (-not (Test-RangerInstalled)) {
        Write-LogInfo "ranger is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    # Try pip first if Python is available
    if (Test-PythonInstalled) {
        Write-LogInfo "Trying pip..."
        $uninstalled = Uninstall-RangerWithPip
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-RangerWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall ranger with any available package manager"
        exit 1
    }

    Test-RangerUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
