# Uninstall script for gpustat on Windows

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

# Get Python command
function Get-PythonCommand {
    $pythonCommands = @("python", "python3", "py")
    foreach ($cmd in $pythonCommands) {
        try {
            $null = & $cmd --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                return $cmd
            }
        } catch {
            continue
        }
    }
    return $null
}

# Check if gpustat is installed
function Test-GpustatInstalled {
    $gpustatCommand = Get-Command gpustat -ErrorAction SilentlyContinue
    return $null -ne $gpustatCommand
}

# Uninstall gpustat
function Uninstall-Gpustat {
    param([Parameter(Mandatory=$true)][string]$PythonCmd)

    Write-LogInfo "Uninstalling gpustat via pip..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            & $PythonCmd -m pip uninstall -y gpustat 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "gpustat uninstalled successfully"
                return $true
            }
        } catch {
            Write-LogInfo "Uninstall attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to uninstall gpustat after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Verify uninstallation
function Test-GpustatUninstalled {
    Write-LogInfo "Verifying gpustat uninstallation..."

    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    if (Test-GpustatInstalled) {
        Write-LogError "gpustat is still installed"
        return $false
    }

    Write-LogSuccess "gpustat has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting gpustat uninstallation on Windows..."

    if (-not (Test-GpustatInstalled)) {
        Write-LogInfo "gpustat is not installed, nothing to uninstall"
        exit 0
    }

    $pythonCmd = Get-PythonCommand
    if (-not $pythonCmd) {
        Write-LogError "Python is required for uninstallation"
        exit 1
    }

    if (-not (Uninstall-Gpustat -PythonCmd $pythonCmd)) {
        exit 1
    }

    Test-GpustatUninstalled | Out-Null

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
