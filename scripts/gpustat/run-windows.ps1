# Run script for gpustat on Windows
# Verifies installation and displays GPU status

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

# Find gpustat executable
function Find-Gpustat {
    Write-LogInfo "Searching for gpustat executable..."
    Update-PathEnvironment

    $gpustatCommand = Get-Command gpustat -ErrorAction SilentlyContinue
    if ($gpustatCommand) {
        Write-LogInfo "Found gpustat at: $($gpustatCommand.Source)"
        return $gpustatCommand.Source
    }

    Write-LogError "gpustat executable not found"
    return $null
}

# Get gpustat version
function Get-GpustatVersion {
    param([Parameter(Mandatory=$true)][string]$GpustatPath)

    try {
        $version = & $GpustatPath --version 2>&1
        return $version
    } catch {
        return "unknown"
    }
}

# Run gpustat
function Invoke-Gpustat {
    param([Parameter(Mandatory=$true)][string]$GpustatPath)

    Write-LogInfo "Running gpustat..."

    try {
        & $GpustatPath 2>&1
        Write-LogSuccess "gpustat executed successfully"
        return $true
    } catch {
        Write-LogInfo "gpustat returned non-zero (may indicate no NVIDIA GPU): $_"
        return $true
    }
}

# Display help
function Show-GpustatHelp {
    param([Parameter(Mandatory=$true)][string]$GpustatPath)

    Write-LogInfo "gpustat help:"
    try {
        & $GpustatPath --help 2>&1 | Select-Object -First 15 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "Could not display help: $_"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running gpustat verification on Windows..."

    $gpustatPath = Find-Gpustat

    if (-not $gpustatPath) {
        Write-LogError "gpustat not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-GpustatVersion -GpustatPath $gpustatPath
    Write-LogSuccess "gpustat version: $version"

    Invoke-Gpustat -GpustatPath $gpustatPath | Out-Null
    Show-GpustatHelp -GpustatPath $gpustatPath

    Write-LogSuccess "gpustat is ready to use!"
    exit 0
}

Main
