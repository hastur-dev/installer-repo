# Run script for JavaScript (Node.js) on Windows
# Verifies installation and displays Node.js info

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

# Find node executable
function Find-Node {
    Write-LogInfo "Searching for Node.js executable..."
    Update-PathEnvironment

    $nodeCommand = Get-Command node -ErrorAction SilentlyContinue
    if ($nodeCommand) {
        Write-LogInfo "Found node at: $($nodeCommand.Source)"
        return $nodeCommand.Source
    }

    Write-LogError "Node.js executable not found"
    return $null
}

# Get node version
function Get-NodeVersion {
    param([Parameter(Mandatory=$true)][string]$NodePath)

    try {
        $version = & $NodePath --version 2>&1
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve Node.js version"
            return $null
        }
        return $version
    } catch {
        Write-LogError "Failed to get Node.js version: $_"
        return $null
    }
}

# Run node smoke test
function Invoke-NodeSmokeTest {
    param([Parameter(Mandatory=$true)][string]$NodePath)

    Write-LogInfo "Running JavaScript smoke test..."

    try {
        & $NodePath -e "console.log('Hello from JavaScript!')" 2>&1
        Write-LogSuccess "JavaScript smoke test passed"
        return $true
    } catch {
        Write-LogError "JavaScript smoke test failed: $_"
        return $false
    }
}

# Display node info
function Show-NodeInfo {
    param([Parameter(Mandatory=$true)][string]$NodePath)

    Write-LogInfo "Node.js info:"
    try {
        & $NodePath -e "console.log('Platform:', process.platform); console.log('Arch:', process.arch); console.log('Version:', process.version)" 2>&1
    } catch {
        Write-LogInfo "Could not get Node.js info"
    }

    Write-LogInfo "npm version:"
    try {
        & npm --version 2>&1
    } catch {
        Write-LogInfo "npm not available"
    }

    Write-LogInfo "Node.js help:"
    try {
        & $NodePath --help 2>&1 | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "Could not display help"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running JavaScript (Node.js) verification on Windows..."

    $nodePath = Find-Node

    if (-not $nodePath) {
        Write-LogError "Node.js not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-NodeVersion -NodePath $nodePath
    if ($version) {
        Write-LogSuccess "Node.js version: $version"
    }

    Invoke-NodeSmokeTest -NodePath $nodePath | Out-Null
    Show-NodeInfo -NodePath $nodePath

    Write-LogSuccess "JavaScript (Node.js) is ready to use!"
    exit 0
}

Main
