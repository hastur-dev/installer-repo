# Uninstall script for Deno on Windows

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

# Check if Deno is installed
function Test-DenoInstalled {
    $denoCommand = Get-Command deno -ErrorAction SilentlyContinue
    if ($denoCommand) {
        return $true
    }
    # Check common install locations
    $denoPath = "$env:USERPROFILE\.deno\bin\deno.exe"
    if (Test-Path $denoPath) {
        return $true
    }
    return $false
}

# Uninstall Deno using winget
function Uninstall-DenoWithWinget {
    Write-LogInfo "Uninstalling Deno via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget uninstall --id DenoLand.Deno --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "not found") {
                Write-LogSuccess "Deno uninstalled successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Deno via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall Deno using Chocolatey
function Uninstall-DenoWithChocolatey {
    Write-LogInfo "Uninstalling Deno via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco uninstall deno -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Deno uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to uninstall Deno via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Remove manual installation
function Remove-DenoManualInstall {
    Write-LogInfo "Checking for manual Deno installation..."
    $denoDir = "$env:USERPROFILE\.deno"
    if (Test-Path $denoDir) {
        Write-LogInfo "Removing Deno directory: $denoDir"
        Remove-Item -Path $denoDir -Recurse -Force
        Write-LogSuccess "Deno directory removed"
        return $true
    }
    return $false
}

# Verify uninstallation
function Test-DenoUninstalled {
    Write-LogInfo "Verifying Deno uninstallation..."
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-DenoInstalled) {
        Write-LogError "Deno is still installed"
        return $false
    }
    Write-LogSuccess "Deno has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Deno uninstallation on Windows..."

    if (-not (Test-DenoInstalled)) {
        Write-LogInfo "Deno is not installed, nothing to uninstall"
        exit 0
    }

    try {
        $denoVersion = deno --version 2>&1 | Select-Object -First 1
        Write-LogInfo "Current Deno installation: $denoVersion"
    } catch {
        Write-LogInfo "Could not determine Deno version"
    }

    $uninstalled = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "Trying winget..."
        $uninstalled = Uninstall-DenoWithWinget
    }

    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Trying Chocolatey..."
        $uninstalled = Uninstall-DenoWithChocolatey
    }

    # Try removing manual installation
    if (-not $uninstalled) {
        $uninstalled = Remove-DenoManualInstall
    }

    if (-not $uninstalled) {
        Write-LogError "Failed to uninstall Deno"
        exit 1
    }

    Test-DenoUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
