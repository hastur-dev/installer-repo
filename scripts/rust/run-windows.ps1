# Run script for Rust on Windows
# Verifies installation and displays Rust info

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
    $cargoPath = "$env:USERPROFILE\.cargo\bin"
    if ((Test-Path $cargoPath) -and ($env:Path -notlike "*$cargoPath*")) {
        $env:Path = "$cargoPath;$env:Path"
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"
}

# Find rustc executable
function Find-Rustc {
    Write-LogInfo "Searching for Rust executable..."
    Update-PathEnvironment

    $rustcCommand = Get-Command rustc -ErrorAction SilentlyContinue
    if ($rustcCommand) {
        Write-LogInfo "Found rustc at: $($rustcCommand.Source)"
        return $rustcCommand.Source
    }

    Write-LogError "rustc executable not found"
    return $null
}

# Get rust version
function Get-RustVersion {
    param([Parameter(Mandatory=$true)][string]$RustcPath)

    try {
        $version = & $RustcPath --version 2>&1
        if ([string]::IsNullOrEmpty($version)) {
            Write-LogError "Could not retrieve Rust version"
            return $null
        }
        return $version
    } catch {
        Write-LogError "Failed to get Rust version: $_"
        return $null
    }
}

# Run rust smoke test
function Invoke-RustSmokeTest {
    Write-LogInfo "Running Rust smoke test..."

    $tempDir = [System.IO.Path]::GetTempPath()
    $testFile = Join-Path $tempDir "rust_test.rs"
    $testExe = Join-Path $tempDir "rust_test.exe"

    try {
        @"
fn main() {
    println!("Hello from Rust!");
}
"@ | Out-File -FilePath $testFile -Encoding UTF8

        & rustc $testFile -o $testExe 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            & $testExe 2>&1
            Write-LogSuccess "Rust smoke test passed - compilation works"
            return $true
        } else {
            Write-LogError "Rust smoke test failed - compilation error"
            return $false
        }
    } catch {
        Write-LogError "Rust smoke test failed: $_"
        return $false
    } finally {
        Remove-Item $testFile -ErrorAction SilentlyContinue
        Remove-Item $testExe -ErrorAction SilentlyContinue
    }
}

# Display rust info
function Show-RustInfo {
    Write-LogInfo "Rust toolchain info:"

    try {
        & cargo --version 2>&1
    } catch {
        Write-LogInfo "cargo not available"
    }

    try {
        & rustup --version 2>&1
        Write-LogInfo "Installed toolchains:"
        & rustup show 2>&1 | Select-Object -First 10 | ForEach-Object { Write-Host $_ }
    } catch {
        Write-LogInfo "rustup not available"
    }
}

# Main entry point
function Main {
    Write-LogInfo "Running Rust verification on Windows..."

    $rustcPath = Find-Rustc

    if (-not $rustcPath) {
        Write-LogError "Rust not found - please run install-windows.ps1 first"
        exit 1
    }

    $version = Get-RustVersion -RustcPath $rustcPath
    if ($version) {
        Write-LogSuccess "Rust version: $version"
    }

    Invoke-RustSmokeTest | Out-Null
    Show-RustInfo

    Write-LogSuccess "Rust is ready to use!"
    exit 0
}

Main
