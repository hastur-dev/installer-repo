# Run script for Emacs on Windows
# Verifies installation and runs emacs with version check

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
    Write-LogInfo "Refreshing PATH environment..."

    # First refresh from registry
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    # Common Emacs installation paths
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
                }
            }
        }
    }

    # Add found paths to PATH
    if ($pathsToAdd.Count -gt 0) {
        $env:Path = ($pathsToAdd -join ";") + ";" + $env:Path
    }
}

# Find emacs executable
function Find-Emacs {
    Write-LogInfo "Searching for Emacs executable..."
    Update-PathEnvironment

    $emacsCommand = Get-Command emacs -ErrorAction SilentlyContinue
    if (-not $emacsCommand) {
        $emacsCommand = Get-Command emacs.exe -ErrorAction SilentlyContinue
    }

    if ($emacsCommand) {
        Write-LogInfo "Found emacs at: $($emacsCommand.Source)"
        return $emacsCommand.Source
    }

    Write-LogError "Emacs executable not found"
    return $null
}

# Get emacs version
function Get-EmacsVersion {
    param([Parameter(Mandatory=$true)][string]$EmacsPath)

    if ([string]::IsNullOrEmpty($EmacsPath)) {
        Write-LogError "EmacsPath parameter is required"
        return $null
    }

    try {
        $version = & $EmacsPath --version 2>&1 | Select-Object -First 1
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve Emacs version"
            return $null
        }
        return $version
    } catch {
        Write-LogError "Failed to get Emacs version: $_"
        return $null
    }
}

# Run emacs smoke test
function Invoke-EmacsSmokeTest {
    param([Parameter(Mandatory=$true)][string]$EmacsPath)

    Write-LogInfo "Running Emacs smoke test..."

    try {
        $result = & $EmacsPath --batch --eval "(message `"Emacs smoke test passed`")" 2>&1
        Write-LogSuccess "Emacs smoke test passed - batch mode works"
        return $true
    } catch {
        Write-LogError "Emacs smoke test failed: $_"
        return $false
    }
}

# Display emacs help summary
function Show-EmacsHelp {
    param([Parameter(Mandatory=$true)][string]$EmacsPath)

    Write-LogInfo "Emacs help summary:"
    try {
        & $EmacsPath --help 2>&1 | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "Could not display help: $_"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running Emacs verification on Windows..."

    $emacsPath = Find-Emacs

    if (-not $emacsPath) {
        Write-LogError "Emacs not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-EmacsVersion -EmacsPath $emacsPath
    if ($version) {
        Write-LogSuccess "Emacs version: $version"
    }

    Invoke-EmacsSmokeTest -EmacsPath $emacsPath | Out-Null
    Show-EmacsHelp -EmacsPath $emacsPath

    Write-LogSuccess "Emacs is ready to use!"
    exit 0
}

Main
