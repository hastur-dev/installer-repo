# Install script for pip on Windows
# pip comes with Python, so this ensures Python is installed

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

# Install Python using winget
function Install-PythonWithWinget {
    Write-LogInfo "Installing Python (which includes pip) via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget install --id Python.Python.3.12 --accept-source-agreements --accept-package-agreements --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "Python installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Python via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install Python using Chocolatey
function Install-PythonWithChocolatey {
    Write-LogInfo "Installing Python (which includes pip) via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install python -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Python installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Python via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH environment
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."
    $pythonPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\*",
        "$env:ProgramFiles\Python*",
        "$env:ProgramFiles(x86)\Python*"
    )
    foreach ($pattern in $pythonPaths) {
        $matches = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            if ($env:Path -notlike "*$($match.FullName)*") {
                $env:Path = "$($match.FullName);$($match.FullName)\Scripts;$env:Path"
            }
        }
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify installation
function Test-PipInstallation {
    Write-LogInfo "Verifying pip installation..."
    Update-PathEnvironment

    # Try different pip commands
    $pipCommand = Get-Command pip3 -ErrorAction SilentlyContinue
    if (-not $pipCommand) {
        $pipCommand = Get-Command pip -ErrorAction SilentlyContinue
    }

    if (-not $pipCommand) {
        # Try via python module
        $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
        if (-not $pythonCommand) {
            $pythonCommand = Get-Command py -ErrorAction SilentlyContinue
        }

        if ($pythonCommand) {
            try {
                $pipVersion = & $pythonCommand.Source -m pip --version 2>&1
                if (-not [string]::IsNullOrEmpty($pipVersion)) {
                    Write-LogSuccess "pip verified: $pipVersion"
                    return $true
                }
            } catch {
                # Continue to error
            }
        }

        Write-LogError "pip command not found after installation"
        return $false
    }

    try {
        $pipVersion = & $pipCommand.Source --version 2>&1

        if ([string]::IsNullOrEmpty($pipVersion)) {
            Write-LogError "Could not retrieve pip version"
            return $false
        }

        Write-LogSuccess "pip verified: $pipVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify pip: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting pip installation on Windows..."

    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }

    $installed = $false

    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-PythonWithWinget
    }

    if (-not $installed) {
        Write-LogInfo "Trying Chocolatey..."
        if (-not (Test-ChocolateyInstalled)) {
            $chocoInstalled = Install-Chocolatey
            if (-not $chocoInstalled) {
                Write-LogError "Could not set up Chocolatey"
                exit 1
            }
        }
        $installed = Install-PythonWithChocolatey
    }

    if (-not $installed) {
        Write-LogError "Failed to install pip with any available package manager"
        exit 1
    }

    if (-not (Test-PipInstallation)) {
        Write-LogError "pip installation verification failed"
        exit 1
    }

    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
