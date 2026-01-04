# Uninstall script for Vim on Windows
# Supports winget and Chocolatey

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

# Check if Vim is installed
function Test-VimInstalled {
    # Check via command
    $vimCommand = Get-Command vim -ErrorAction SilentlyContinue
    if ($vimCommand) {
        return $true
    }

    $vimExe = Get-Command vim.exe -ErrorAction SilentlyContinue
    if ($vimExe) {
        return $true
    }

    # Check common installation paths
    $vimPaths = @(
        "$env:ProgramFiles\Vim",
        "${env:ProgramFiles(x86)}\Vim",
        "$env:LOCALAPPDATA\Programs\Vim",
        "C:\tools\vim"
    )

    foreach ($path in $vimPaths) {
        if (Test-Path $path) {
            return $true
        }
    }

    return $false
}

# Uninstall Vim using winget
function Uninstall-VimWithWinget {
    Write-LogInfo "Uninstalling Vim via winget..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++

        try {
            $result = winget uninstall --id vim.vim --silent 2>&1

            if ($LASTEXITCODE -eq 0 -or $result -match "successfully uninstalled") {
                Write-LogSuccess "Vim uninstalled successfully via winget"
                return $true
            }

            if ($result -match "No installed package found") {
                Write-LogInfo "Vim not found in winget, may be installed via other method"
                return $false
            }
        } catch {
            Write-LogInfo "Winget uninstall attempt $attempt failed: $_"
        }

        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to uninstall Vim via winget after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Uninstall Vim using Chocolatey
function Uninstall-VimWithChocolatey {
    Write-LogInfo "Uninstalling Vim via Chocolatey..."

    $attempt = 0
    while ($attempt -lt $MAX_RETRY_ATTEMPTS) {
        $attempt++

        try {
            choco uninstall vim -y --no-progress 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "Vim uninstalled successfully via Chocolatey"
                return $true
            }
        } catch {
            Write-LogInfo "Chocolatey uninstall attempt $attempt failed: $_"
        }

        Write-LogInfo "Retrying ($attempt/$MAX_RETRY_ATTEMPTS)..."
        Start-Sleep -Seconds $RETRY_DELAY_SECONDS
    }

    Write-LogError "Failed to uninstall Vim via Chocolatey after $MAX_RETRY_ATTEMPTS attempts"
    return $false
}

# Clean up configuration files (optional)
function Remove-VimConfig {
    Write-LogInfo "Cleaning up Vim configuration files..."

    $configPaths = @(
        "$env:USERPROFILE\_vimrc",
        "$env:USERPROFILE\.vimrc",
        "$env:USERPROFILE\vimfiles",
        "$env:USERPROFILE\.vim"
    )

    foreach ($path in $configPaths) {
        if (Test-Path $path) {
            Write-LogInfo "Removing: $path"
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-LogInfo "Configuration cleanup complete"
}

# Refresh PATH environment
function Update-PathEnvironment {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Verify uninstallation
function Test-VimUninstalled {
    Write-LogInfo "Verifying Vim uninstallation..."

    Update-PathEnvironment

    if (Test-VimInstalled) {
        Write-LogError "Vim is still installed"
        return $false
    }

    Write-LogSuccess "Vim has been removed from the system"
    return $true
}

# Main entry point
function Main {
    Write-LogInfo "Starting Vim uninstallation on Windows..."

    # Check if Vim is installed
    if (-not (Test-VimInstalled)) {
        Write-LogInfo "Vim is not installed, nothing to uninstall"
        exit 0
    }

    $uninstalled = $false

    # Try winget first
    if (Test-WingetInstalled) {
        Write-LogInfo "Attempting uninstall via winget..."
        $uninstalled = Uninstall-VimWithWinget
    }

    # Try Chocolatey if winget didn't work
    if (-not $uninstalled -and (Test-ChocolateyInstalled)) {
        Write-LogInfo "Attempting uninstall via Chocolatey..."
        $uninstalled = Uninstall-VimWithChocolatey
    }

    if (-not $uninstalled) {
        Write-LogError "Could not uninstall Vim via package managers"
        Write-LogInfo "You may need to uninstall Vim manually via Control Panel"
        exit 1
    }

    # Optional: Clean up config files
    # Uncomment the next line to remove config files
    # Remove-VimConfig

    # Verify
    if (-not (Test-VimUninstalled)) {
        Write-LogError "Uninstallation verification failed"
        exit 1
    }

    Write-LogSuccess "Uninstallation complete!"
    exit 0
}

Main
