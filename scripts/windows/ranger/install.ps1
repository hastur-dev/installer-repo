# Install script for ranger on Windows
# Note: ranger is a Python-based file manager, typically used on Unix systems
# On Windows, it requires Python and pip to install

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

function Write-LogWarn {
    param([Parameter(Mandatory=$true)][string]$Message)
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }
    Write-Host "[WARN] ${SCRIPT_NAME}: $Message" -ForegroundColor Yellow
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

# Install ranger using pip
function Install-RangerWithPip {
    Write-LogInfo "Installing ranger via pip..."
    Write-LogWarn "ranger is primarily designed for Unix systems and may have limited functionality on Windows"

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $pythonCmd = if (Get-Command python -ErrorAction SilentlyContinue) { "python" } else { "python3" }
            $result = & $pythonCmd -m pip install ranger-fm 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ranger installed successfully via pip"
                return $true
            }
        } catch {
            Write-LogInfo "Pip install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install ranger via pip after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install ranger using Chocolatey (fallback - may not be available)
function Install-RangerWithChocolatey {
    Write-LogInfo "Attempting to install ranger via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install ranger -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "ranger installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install ranger via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed ranger
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-RangerInstallation {
    Write-LogInfo "Verifying ranger installation..."
    Update-PathEnvironment

    $rangerCommand = Get-Command ranger -ErrorAction SilentlyContinue

    if (-not $rangerCommand) {
        Write-LogError "ranger command not found after installation"
        return $false
    }

    try {
        $rangerVersion = & $rangerCommand.Source --version 2>&1 | Select-Object -First 1

        if ([string]::IsNullOrEmpty($rangerVersion)) {
            Write-LogError "Could not retrieve ranger version"
            return $false
        }

        Write-LogSuccess "ranger verified: $rangerVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify ranger: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting ranger installation on Windows..."
    Write-LogWarn "Note: ranger is primarily designed for Unix-like systems (Linux/macOS)"
    Write-LogWarn "Consider using alternatives like lf or yazi for better Windows support"

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    # Try pip first if Python is available
    if (Test-PythonInstalled) {
        Write-LogInfo "Python detected, attempting pip installation..."
        $installed = Install-RangerWithPip
    }

    # Try Chocolatey as fallback
    if (-not $installed) {
        Write-LogInfo "Trying Chocolatey..."
        if (-not (Test-ChocolateyInstalled)) {
            $chocoInstalled = Install-Chocolatey
            if (-not $chocoInstalled) {
                Write-LogError "Could not set up Chocolatey"
                exit 1
            }
        }
        $installed = Install-RangerWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install ranger with any available method"
        Write-LogInfo "Ensure Python is installed and try: pip install ranger-fm"
        exit 1
    }

    if (-not (Test-RangerInstallation)) {
        Write-LogError "ranger installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
