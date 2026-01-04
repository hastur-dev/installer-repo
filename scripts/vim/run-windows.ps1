# Run script for Vim on Windows
# Verifies installation and runs vim with version check

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$SCRIPT_NAME = "run-windows.ps1"
$MAX_SEARCH_PATHS = 20
$VIM_EXPECTED_PATHS = @(
    "$env:ProgramFiles\Vim\vim*\vim.exe",
    "$env:ProgramFiles(x86)\Vim\vim*\vim.exe",
    "$env:LOCALAPPDATA\Programs\Vim\vim*\vim.exe",
    "C:\tools\vim\vim*\vim.exe"
)

# Logging functions
function Write-LogInfo {
    param([Parameter(Mandatory=$true)][string]$Message)

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[INFO] ${SCRIPT_NAME}: $Message"
}

function Write-LogError {
    param([Parameter(Mandatory=$true)][string]$Message)

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[ERROR] ${SCRIPT_NAME}: $Message" -ForegroundColor Red
}

function Write-LogSuccess {
    param([Parameter(Mandatory=$true)][string]$Message)

    # Precondition
    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message cannot be empty"
    }

    Write-Host "[SUCCESS] ${SCRIPT_NAME}: $Message" -ForegroundColor Green
}

# Refresh PATH environment
function Update-PathEnvironment {
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Find vim executable
function Find-VimExecutable {
    Write-LogInfo "Searching for Vim executable..."

    Update-PathEnvironment

    # First try command lookup
    $vimCommand = Get-Command vim -ErrorAction SilentlyContinue
    if (-not $vimCommand) {
        $vimCommand = Get-Command vim.exe -ErrorAction SilentlyContinue
    }

    if ($vimCommand) {
        Write-LogInfo "Found vim at: $($vimCommand.Source)"
        return $vimCommand.Source
    }

    # Search common paths (bounded loop)
    $iteration = 0
    foreach ($pattern in $VIM_EXPECTED_PATHS) {
        $iteration++
        if ($iteration -gt $MAX_SEARCH_PATHS) {
            Write-LogError "Exceeded search iteration limit"
            return $null
        }

        $matches = Get-ChildItem -Path $pattern -ErrorAction SilentlyContinue
        foreach ($match in $matches) {
            if (Test-Path $match.FullName) {
                Write-LogInfo "Found vim at: $($match.FullName)"
                return $match.FullName
            }
        }
    }

    Write-LogError "Vim executable not found"
    return $null
}

# Get vim version
function Get-VimVersion {
    param([Parameter(Mandatory=$true)][string]$VimPath)

    # Precondition
    if ([string]::IsNullOrEmpty($VimPath)) {
        throw "VimPath cannot be empty"
    }
    if (-not (Test-Path $VimPath)) {
        throw "VimPath must exist: $VimPath"
    }

    try {
        $version = & $VimPath --version 2>&1 | Select-Object -First 1

        # Postcondition
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve Vim version"
            return $null
        }

        return $version
    } catch {
        Write-LogError "Failed to get Vim version: $_"
        return $null
    }
}

# Run vim smoke test
function Invoke-VimSmokeTest {
    param([Parameter(Mandatory=$true)][string]$VimPath)

    # Precondition
    if ([string]::IsNullOrEmpty($VimPath)) {
        throw "VimPath cannot be empty"
    }

    Write-LogInfo "Running Vim smoke test..."

    # Create a temporary test file
    $testFile = [System.IO.Path]::GetTempFileName()

    try {
        # Write to file using vim in ex mode (non-interactive)
        $testContent = "Test content from vim smoke test"
        $testContent | Out-File -FilePath $testFile -Encoding UTF8

        # Read with vim and verify
        $result = & $VimPath -e -s -c "q" $testFile 2>&1

        # Verify file exists
        if (Test-Path $testFile) {
            Write-LogSuccess "Vim smoke test passed - file operations work"
            return $true
        } else {
            Write-LogError "Vim smoke test failed - file was not created"
            return $false
        }
    } catch {
        Write-LogError "Vim smoke test failed: $_"
        return $false
    } finally {
        # Cleanup
        if (Test-Path $testFile) {
            Remove-Item $testFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Display vim help summary
function Show-VimHelpSummary {
    param([Parameter(Mandatory=$true)][string]$VimPath)

    # Precondition
    if ([string]::IsNullOrEmpty($VimPath)) {
        throw "VimPath cannot be empty"
    }

    Write-LogInfo "Vim help summary:"

    try {
        $help = & $VimPath --help 2>&1 | Select-Object -First 10
        $help | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "Could not display help: $_"
    }
}

# Show installation info
function Show-InstallationInfo {
    param([Parameter(Mandatory=$true)][string]$VimPath)

    # Precondition
    if ([string]::IsNullOrEmpty($VimPath)) {
        throw "VimPath cannot be empty"
    }

    Write-LogInfo "Installation details:"
    Write-Host "  Path: $VimPath"

    $fileInfo = Get-Item $VimPath
    Write-Host "  Size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB"
    Write-Host "  Modified: $($fileInfo.LastWriteTime)"
}

# Main entry point
function Main {
    Write-LogInfo "Running Vim verification on Windows..."

    # Find vim
    $vimPath = Find-VimExecutable

    # Postcondition check
    if ([string]::IsNullOrEmpty($vimPath)) {
        Write-LogError "Vim not found - please run install-windows.ps1 first"
        exit 1
    }

    # Get version
    $version = Get-VimVersion -VimPath $vimPath
    if ($version) {
        Write-LogSuccess "Vim version: $version"
    }

    # Run smoke test
    $smokeResult = Invoke-VimSmokeTest -VimPath $vimPath
    if (-not $smokeResult) {
        Write-LogError "Smoke test failed"
        exit 1
    }

    # Show installation info
    Show-InstallationInfo -VimPath $vimPath

    # Display help
    Show-VimHelpSummary -VimPath $vimPath

    Write-LogSuccess "Vim is ready to use!"
    exit 0
}

Main
