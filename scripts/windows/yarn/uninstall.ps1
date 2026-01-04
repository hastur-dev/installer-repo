# Uninstall script for Yarn on Windows

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

function Write-LogWarn {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow
}

# Check if Yarn is installed
function Test-YarnInstalled {
    $yarnCommand = Get-Command yarn -ErrorAction SilentlyContinue
    if ($yarnCommand) {
        return $true
    }
    return $false
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

# Check if Chocolatey is available
function Test-ChocolateyInstalled {
    try {
        $null = Get-Command choco -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Uninstall Yarn via npm
function Uninstall-YarnViaNpm {
    Write-LogInfo "Uninstalling Yarn via npm..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            npm uninstall -g yarn 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Yarn uninstalled successfully via npm"
                return $true
            }
        } catch {
            Write-LogInfo "npm uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Disable Yarn via corepack
function Disable-YarnViaCorepack {
    Write-LogInfo "Disabling Yarn via corepack..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            corepack disable yarn 2>&1 | Out-Null
            Write-LogSuccess "Yarn disabled via corepack"
            return $true
        } catch {
            Write-LogInfo "Corepack disable attempt $attempt failed: $_"
        }
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Uninstall Yarn via Chocolatey
function Uninstall-YarnViaChocolatey {
    Write-LogInfo "Uninstalling Yarn via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall yarn -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Yarn uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    return $false
}

# Verify uninstallation
function Test-YarnUninstalled {
    Write-LogInfo "Verifying Yarn uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-YarnInstalled) {
        Write-LogWarn "Yarn is still installed"
        return $false
    }
    Write-LogSuccess "Yarn has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Yarn uninstallation on Windows..."

    if (-not (Test-YarnInstalled)) {
        Write-LogInfo "Yarn is not installed, nothing to uninstall"
        exit 0
    }

    $yarnVersion = & yarn --version 2>&1
    Write-LogInfo "Current Yarn installation: $yarnVersion"

    $uninstalled = $false

    # Try corepack disable
    if (Test-CorepackAvailable) {
        Disable-YarnViaCorepack | Out-Null
    }

    # Try npm uninstall
    if (Test-NpmInstalled) {
        $uninstalled = Uninstall-YarnViaNpm
    }

    # Try Chocolatey
    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        $uninstalled = Uninstall-YarnViaChocolatey
    }

    if (-not $uninstalled) {
        Write-LogWarn "Could not uninstall Yarn via package manager"
        Write-LogInfo "You may need to manually remove Yarn"
    }

    Test-YarnUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
