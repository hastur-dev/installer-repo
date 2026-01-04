# Install script for Emacs on Windows
# Supports winget (preferred) and Chocolatey as fallback

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

# Install Emacs using winget
function Install-EmacsWithWinget {
    Write-LogInfo "Installing Emacs via winget..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            $result = winget install --id GNU.Emacs --accept-source-agreements --accept-package-agreements --silent 2>&1
            if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
                Write-LogSuccess "Emacs installed successfully via winget"
                return $true
            }
        } catch {
            Write-LogInfo "Winget install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Emacs via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Install Emacs using Chocolatey
function Install-EmacsWithChocolatey {
    Write-LogInfo "Installing Emacs via Chocolatey..."
    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++
        try {
            choco install emacs -y --no-progress 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Emacs installed successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey install attempt $attempt failed: $_"
        }
        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }
    Write-LogError "Failed to install Emacs via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Refresh PATH to find newly installed emacs
function Update-PathEnvironment {
    Write-LogInfo "Refreshing PATH environment..."

    # First refresh from registry
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    # Common Emacs installation paths (winget, choco, manual)
    $emacsPaths = @(
        "$env:ProgramFiles\Emacs\emacs-*\bin",
        "$env:ProgramFiles\Emacs\*\bin",
        "${env:ProgramFiles(x86)}\Emacs\emacs-*\bin",
        "${env:ProgramFiles(x86)}\Emacs\*\bin",
        "$env:LOCALAPPDATA\Programs\Emacs\emacs-*\bin",
        "$env:LOCALAPPDATA\Programs\Emacs\*\bin",
        "C:\tools\emacs\*\bin",
        "C:\emacs\*\bin",
        "C:\Emacs\emacs-*\bin"
    )

    $pathsToAdd = @()
    foreach ($pattern in $emacsPaths) {
        try {
            $foundPaths = Get-ChildItem -Path $pattern -Directory -ErrorAction SilentlyContinue
            foreach ($foundPath in $foundPaths) {
                if ((Test-Path $foundPath.FullName) -and ($pathsToAdd -notcontains $foundPath.FullName)) {
                    $pathsToAdd += $foundPath.FullName
                    Write-LogInfo "Found Emacs bin directory: $($foundPath.FullName)"
                }
            }
        } catch {
            # Ignore pattern match errors
        }
    }

    # Also check for direct emacs.exe in common locations
    $directPaths = @(
        "$env:ProgramFiles\Emacs",
        "${env:ProgramFiles(x86)}\Emacs",
        "$env:LOCALAPPDATA\Programs\Emacs"
    )
    foreach ($basePath in $directPaths) {
        if (Test-Path $basePath) {
            $binDirs = Get-ChildItem -Path $basePath -Recurse -Filter "emacs.exe" -ErrorAction SilentlyContinue |
                       Select-Object -ExpandProperty DirectoryName -Unique
            foreach ($binDir in $binDirs) {
                if ($pathsToAdd -notcontains $binDir) {
                    $pathsToAdd += $binDir
                    Write-LogInfo "Found Emacs at: $binDir"
                }
            }
        }
    }

    # Add found paths to PATH
    if ($pathsToAdd.Count -gt 0) {
        $env:Path = ($pathsToAdd -join ";") + ";" + $env:Path
    }
}

# Verify installation
function Test-EmacsInstallation {
    Write-LogInfo "Verifying Emacs installation..."
    Update-PathEnvironment
    $emacsCommand = Get-Command emacs -ErrorAction SilentlyContinue
    if (-not $emacsCommand) {
        $emacsCommand = Get-Command emacs.exe -ErrorAction SilentlyContinue
    }
    if (-not $emacsCommand) {
        Write-LogError "Emacs command not found after installation"
        return $false
    }
    try {
        $emacsVersion = & $emacsCommand.Source --version 2>&1 | Select-Object -First 1
        if ([string]::IsNullOrEmpty($emacsVersion)) {
            Write-LogError "Could not retrieve Emacs version"
            return $false
        }
        Write-LogSuccess "Emacs verified: $emacsVersion"
        return $true
    } catch {
        Write-LogError "Failed to verify Emacs: $_"
        return $false
    }
}

# Main entry point
function Main {
    Write-LogInfo "Starting Emacs installation on Windows..."
    if (-not (Test-WindowsEnvironment)) {
        exit 1
    }
    $installed = $false
    if (Test-WingetInstalled) {
        Write-LogInfo "winget detected, using it for installation..."
        $installed = Install-EmacsWithWinget
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
        $installed = Install-EmacsWithChocolatey
    }
    if (-not $installed) {
        Write-LogError "Failed to install Emacs with any available package manager"
        exit 1
    }
    if (-not (Test-EmacsInstallation)) {
        Write-LogError "Emacs installation verification failed"
        exit 1
    }
    Write-LogSuccess "Installation complete!"
    exit 0
}

Main
