# Uninstall script for pip on Windows
# Note: pip comes with Python, so this provides warnings

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

# Check if pip is installed
function Test-PipInstalled {
    $pipCommand = Get-Command pip3 -ErrorAction SilentlyContinue
    if ($pipCommand) {
        return $true
    }
    $pipCommand = Get-Command pip -ErrorAction SilentlyContinue
    if ($pipCommand) {
        return $true
    }
    # Try via python module
    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        try {
            $result = & python -m pip --version 2>&1
            if (-not [string]::IsNullOrEmpty($result)) {
                return $true
            }
        } catch {
            # Continue
        }
    }
    return $false
}

# Main entry point
function Main {
    Write-LogInfo "Starting pip uninstallation check on Windows..."

    Write-LogWarn "pip is bundled with Python and cannot be uninstalled separately."
    Write-LogWarn "To remove pip, you would need to uninstall Python."
    Write-LogWarn "This script will NOT uninstall pip/Python to prevent issues."
    Write-Host ""
    Write-LogInfo "If you need to remove Python (and thus pip), use:"
    Write-LogInfo "  winget uninstall --id Python.Python.3.12"
    Write-LogInfo "  or"
    Write-LogInfo "  choco uninstall python"
    Write-Host ""
    Write-LogInfo "Consider using virtual environments (venv) instead."

    if (Test-PipInstalled) {
        $pipCommand = Get-Command pip3 -ErrorAction SilentlyContinue
        if (-not $pipCommand) {
            $pipCommand = Get-Command pip -ErrorAction SilentlyContinue
        }

        if ($pipCommand) {
            $pipVersion = & $pipCommand.Source --version 2>&1
            Write-LogInfo "Current pip installation: $pipVersion"
        } else {
            $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
            if ($pythonCommand) {
                $pipVersion = & python -m pip --version 2>&1
                Write-LogInfo "Current pip installation: $pipVersion"
            }
        }
    }

    Write-LogSuccess "No changes made to pip."
    exit 0
}

Main
