# Test suite for install and run scripts (PowerShell)
# Tests script existence, syntax validity, and basic execution

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Constants
$MAX_TEST_ITERATIONS = 100
$SCRIPT_DIR = $PSScriptRoot
if (-not $SCRIPT_DIR) {
    $SCRIPT_DIR = Get-Location
}
$SCRIPT_DIR = Split-Path -Parent $SCRIPT_DIR
$SCRIPTS_PATH = Join-Path $SCRIPT_DIR "scripts" | Join-Path -ChildPath "vim"

# Test counters
$script:TestsRun = 0
$script:TestsPassed = 0
$script:TestsFailed = 0

function Assert-Condition {
    param(
        [Parameter(Mandatory=$true)]
        [bool]$Condition,
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    if ([string]::IsNullOrEmpty($Message)) {
        throw "Message must not be empty"
    }

    $script:TestsRun++

    if ($Condition) {
        $script:TestsPassed++
        Write-Host "[PASS] $Message" -ForegroundColor Green
        return $true
    } else {
        $script:TestsFailed++
        Write-Host "[FAIL] $Message" -ForegroundColor Red
        return $false
    }
}

function Test-ScriptExists {
    param([Parameter(Mandatory=$true)][string]$ScriptName)

    if ([string]::IsNullOrEmpty($ScriptName)) {
        throw "ScriptName must not be empty"
    }

    $scriptPath = Join-Path $SCRIPTS_PATH $ScriptName
    $exists = Test-Path $scriptPath
    Assert-Condition -Condition $exists -Message "Script exists: $ScriptName"
}

function Test-PowerShellSyntax {
    param([Parameter(Mandatory=$true)][string]$ScriptName)

    if ([string]::IsNullOrEmpty($ScriptName)) {
        throw "ScriptName must not be empty"
    }

    if (-not $ScriptName.EndsWith(".ps1")) {
        Write-Host "[SKIP] PowerShell syntax check for: $ScriptName"
        return $true
    }

    $scriptPath = Join-Path $SCRIPTS_PATH $ScriptName

    try {
        $tokens = $null
        $errors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $scriptPath,
            [ref]$tokens,
            [ref]$errors
        )
        $valid = ($errors.Count -eq 0)
        Assert-Condition -Condition $valid -Message "Valid PowerShell syntax: $ScriptName"
    } catch {
        Assert-Condition -Condition $false -Message "Valid PowerShell syntax: $ScriptName"
    }
}

function Test-LineCount {
    param([Parameter(Mandatory=$true)][string]$ScriptName)

    if ([string]::IsNullOrEmpty($ScriptName)) {
        throw "ScriptName must not be empty"
    }

    $scriptPath = Join-Path $SCRIPTS_PATH $ScriptName

    if (-not (Test-Path $scriptPath)) {
        Assert-Condition -Condition $false -Message "Line count check - file missing: $ScriptName"
        return
    }

    $lineCount = (Get-Content $scriptPath | Measure-Object -Line).Lines
    $withinLimit = $lineCount -le 500
    $countMsg = "Line count within limit - " + $lineCount.ToString() + " lines: " + $ScriptName
    Assert-Condition -Condition $withinLimit -Message $countMsg
}

function Test-HasStrictMode {
    param([Parameter(Mandatory=$true)][string]$ScriptName)

    if ([string]::IsNullOrEmpty($ScriptName)) {
        throw "ScriptName must not be empty"
    }

    if (-not $ScriptName.EndsWith(".ps1")) {
        Write-Host "[SKIP] StrictMode check for: $ScriptName"
        return $true
    }

    $scriptPath = Join-Path $SCRIPTS_PATH $ScriptName

    if (-not (Test-Path $scriptPath)) {
        Assert-Condition -Condition $false -Message "StrictMode check - file missing: $ScriptName"
        return
    }

    $content = Get-Content $scriptPath -Raw
    $hasStrict = $content -match "Set-StrictMode"
    Assert-Condition -Condition $hasStrict -Message "Has Set-StrictMode: $ScriptName"
}

function Invoke-AllTests {
    Write-Host "========================================="
    Write-Host "Running Script Tests (PowerShell)"
    Write-Host "Script directory: $SCRIPTS_PATH"
    Write-Host "========================================="
    Write-Host ""

    $installScripts = @("install-linux.sh", "install-macos.sh", "install-windows.ps1")
    $runScripts = @("run-linux.sh", "run-macos.sh", "run-windows.ps1")
    $uninstallScripts = @("uninstall-linux.sh", "uninstall-macos.sh", "uninstall-windows.ps1")
    $allScripts = $installScripts + $runScripts + $uninstallScripts

    $iteration = 0
    foreach ($scriptName in $allScripts) {
        $iteration++
        if ($iteration -gt $MAX_TEST_ITERATIONS) {
            Write-Error "Exceeded max iterations"
            break
        }

        Write-Host "--- Testing: $scriptName ---"
        Test-ScriptExists -ScriptName $scriptName
        Test-PowerShellSyntax -ScriptName $scriptName
        Test-LineCount -ScriptName $scriptName
        Test-HasStrictMode -ScriptName $scriptName
        Write-Host ""
    }

    Write-Host "========================================="
    Write-Host "Test Summary"
    Write-Host "========================================="
    Write-Host "Total:  $($script:TestsRun)"
    Write-Host "Passed: $($script:TestsPassed)"
    Write-Host "Failed: $($script:TestsFailed)"
    Write-Host ""

    $totalCheck = ($script:TestsPassed + $script:TestsFailed) -eq $script:TestsRun
    if (-not $totalCheck) {
        Write-Warning "Test count mismatch detected"
    }

    if ($script:TestsFailed -eq 0) {
        Write-Host "All tests passed!" -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Some tests failed!" -ForegroundColor Red
        exit 1
    }
}

function Main {
    if (-not (Test-Path $SCRIPTS_PATH)) {
        Write-Host "Creating scripts directory for testing..."
        New-Item -ItemType Directory -Path $SCRIPTS_PATH -Force | Out-Null
    }

    Invoke-AllTests
}

Main
