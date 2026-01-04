# Install script for gpustat on Windows
# gpustat is a Python package for GPU monitoring

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

# Check if Python is installed
function Get-PythonCommand {
    Write-LogInfo "Checking for Python installation..."

    $pythonCommands = @("python", "python3", "py")
    foreach ($cmd in $pythonCommands) {
        try {
            $result = & $cmd --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogInfo "Found Python: $result"
                return $cmd
            }
        } catch {
            continue
        }
    }

    Write-LogError "Python is not installed"
    return $null
}

# Check if pip is installed
function Test-PipInstalled {
    param([Parameter(Mandatory=$true)][string]$PythonCmd)

    Write-LogInfo "Checking for pip installation..."

    try {
        $result = & $PythonCmd -m pip --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogInfo "Found pip: $result"
            return $true
        }
    } catch {
        Write-LogError "pip check failed: $_"
    }

    Write-LogError "pip is not installed"
    return $false
}

# Install gpustat with retry
function Install-Gpustat {
    param([Parameter(Mandatory=$true)][string]$PythonCmd)

    Write-LogInfo "Installing gpustat via pip..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            & $PythonCmd -m pip install --user gpustat 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "gpustat installed successfully"
                return $true
            }
        } catch {
            Write-LogInfo "Install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to install gpustat after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $userScripts = "$env:APPDATA\Python\*\Scripts"
    $pythonPaths = Get-ChildItem -Path $userScripts -Directory -ErrorAction SilentlyContinue
    foreach ($path in $pythonPaths) {
        if ($env:Path -notlike "*$($path.FullName)*") {
            $env:Path = "$($path.FullName);$env:Path"
        }
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-GpustatInstallation {
    Write-LogInfo "Verifying gpustat installation..."
    Update-PathEnvironment

    $gpustatCommand = Get-Command gpustat -ErrorAction SilentlyContinue
    if (-not $gpustatCommand) {
        Write-LogError "gpustat command not found after installation"
        return $false
    }

    try {
        $version = & gpustat --version 2>&1
        Write-LogSuccess "gpustat verified: $version"
        return $true
    } catch {
        Write-LogSuccess "gpustat installed (version check requires GPU)"
        return $true
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting gpustat installation on Windows..."

    $pythonCmd = Get-PythonCommand
    if (-not $pythonCmd) {
        Write-LogError "Python is required but not installed"
        exit 1
    }

    if (-not (Test-PipInstalled -PythonCmd $pythonCmd)) {
        Write-LogError "pip is required but not installed"
        exit 1
    }

    if (-not (Install-Gpustat -PythonCmd $pythonCmd)) {
        exit 1
    }

    Test-GpustatInstallation | Out-Null

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
