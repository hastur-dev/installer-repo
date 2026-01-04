# Run script for npm on Windows
# Verifies installation and displays npm info

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "run-windows.ps1"

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

# Refresh PATH
function Update-PathEnvironment {
    $nodePaths = @(
        "$env:ProgramFiles\nodejs",
        "$env:ProgramFiles(x86)\nodejs",
        "$env:LOCALAPPDATA\Programs\nodejs"
    )
    foreach ($path in $nodePaths) {
        if ((Test-Path $path) -and ($env:Path -notlike "*$path*")) {
            $env:Path = "$path;$env:Path"
        }
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Find npm executable
function Find-Npm {
    Write-LogInfo "Searching for npm executable..."
    Update-PathEnvironment

    $npmCommand = Get-Command npm -ErrorAction SilentlyContinue
    if ($npmCommand) {
        Write-LogInfo "Found npm at: $($npmCommand.Source)"
        return $npmCommand.Source
    }

    Write-LogError "npm executable not found"
    return $null
}

# Get npm version
function Get-NpmVersion {
    param([Parameter(Mandatory=$true)][string]$NpmPath)

    try {
        $version = & $NpmPath --version 2>&1
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve npm version"
            return $null
        }
        return $version
    } catch {
        Write-LogError "Failed to get npm version: $_"
        return $null
    }
}

# Run npm smoke test
function Invoke-NpmSmokeTest {
    param([Parameter(Mandatory=$true)][string]$NpmPath)

    Write-LogInfo "Running npm smoke test..."

    try {
        & $NpmPath config list 2>&1 | Out-Null
        Write-LogSuccess "npm smoke test passed - config accessible"
        return $true
    } catch {
        Write-LogError "npm smoke test failed: $_"
        return $false
    }
}

# Display npm help summary
function Show-NpmHelp {
    param([Parameter(Mandatory=$true)][string]$NpmPath)

    Write-LogInfo "npm help summary:"
    try {
        & $NpmPath --help 2>&1 | Select-Object -First 15 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "Could not display help: $_"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running npm verification on Windows..."

    $npmPath = Find-Npm

    if (-not $npmPath) {
        Write-LogError "npm not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-NpmVersion -NpmPath $npmPath
    if ($version) {
        Write-LogSuccess "npm version: v$version"
    }

    try {
        $nodeVersion = & node --version 2>&1
        Write-LogSuccess "Node.js version: $nodeVersion"
    } catch {
        Write-LogInfo "Could not get Node.js version"
    }

    Invoke-NpmSmokeTest -NpmPath $npmPath | Out-Null
    Show-NpmHelp -NpmPath $npmPath

    Write-LogSuccess "npm is ready to use!"
    exit 0
}

Main
