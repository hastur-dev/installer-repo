# Run script for Python on Windows
# Verifies installation and displays Python info

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

# Find python executable
function Find-Python {
    Write-LogInfo "Searching for Python executable..."
    Update-PathEnvironment

    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        Write-LogInfo "Found python at: $($pythonCommand.Source)"
        return $pythonCommand.Source
    }

    $pythonCommand = Get-Command python3 -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        Write-LogInfo "Found python3 at: $($pythonCommand.Source)"
        return $pythonCommand.Source
    }

    $pythonCommand = Get-Command py -ErrorAction SilentlyContinue
    if ($pythonCommand) {
        Write-LogInfo "Found py at: $($pythonCommand.Source)"
        return $pythonCommand.Source
    }

    Write-LogError "Python executable not found"
    return $null
}

# Get python version
function Get-PythonVersion {
    param([Parameter(Mandatory=$true)][string]$PythonPath)

    try {
        $version = & $PythonPath --version 2>&1
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve Python version"
            return $null
        }
        return $version
    } catch {
        Write-LogError "Failed to get Python version: $_"
        return $null
    }
}

# Run python smoke test
function Invoke-PythonSmokeTest {
    param([Parameter(Mandatory=$true)][string]$PythonPath)

    Write-LogInfo "Running Python smoke test..."

    try {
        & $PythonPath -c "print('Hello from Python!')" 2>&1
        Write-LogSuccess "Python smoke test passed"
        return $true
    } catch {
        Write-LogError "Python smoke test failed: $_"
        return $false
    }
}

# Display python info
function Show-PythonInfo {
    param([Parameter(Mandatory=$true)][string]$PythonPath)

    Write-LogInfo "Python system info:"
    try {
        & $PythonPath -c "import sys; print(f'Platform: {sys.platform}'); print(f'Executable: {sys.executable}'); print(f'Version: {sys.version}')" 2>&1
    } catch {
        Write-LogInfo "Could not get system info: $_"
    }

    Write-LogInfo "pip version:"
    try {
        & $PythonPath -m pip --version 2>&1
    } catch {
        Write-LogInfo "pip not available"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running Python verification on Windows..."

    $pythonPath = Find-Python

    if (-not $pythonPath) {
        Write-LogError "Python not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-PythonVersion -PythonPath $pythonPath
    if ($version) {
        Write-LogSuccess "Python version: $version"
    }

    Invoke-PythonSmokeTest -PythonPath $pythonPath | Out-Null
    Show-PythonInfo -PythonPath $pythonPath

    Write-LogSuccess "Python is ready to use!"
    exit 0
}

Main
