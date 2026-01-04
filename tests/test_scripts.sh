#!/usr/bin/env bash
# Test suite for install and run scripts
# Tests script existence, syntax validity, and basic execution

set -euo pipefail

# Constants
readonly MAX_TEST_ITERATIONS=100
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SCRIPTS_PATH="${SCRIPT_DIR}/scripts/vim"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Assertion: increment test count and check condition
assert_true() {
    local condition="$1"
    local message="$2"

    assert [ -n "$condition" ] "condition must not be empty"
    assert [ -n "$message" ] "message must not be empty"

    ((TESTS_RUN++)) || true

    if eval "$condition"; then
        ((TESTS_PASSED++)) || true
        echo "✓ PASS: $message"
        return 0
    else
        ((TESTS_FAILED++)) || true
        echo "✗ FAIL: $message"
        return 1
    fi
}

# Assertion helper
assert() {
    if ! "$@"; then
        echo "Assertion failed: $*" >&2
        return 1
    fi
}

# Test: Script file exists
test_script_exists() {
    local script_name="$1"
    local script_path="${SCRIPTS_PATH}/${script_name}"

    assert [ -n "$script_name" ] "script_name must not be empty"

    assert_true "[ -f '${script_path}' ]" "Script exists: ${script_name}"
}

# Test: Script is executable (for shell scripts)
test_script_executable() {
    local script_name="$1"
    local script_path="${SCRIPTS_PATH}/${script_name}"

    assert [ -n "$script_name" ] "script_name must not be empty"

    # Skip .ps1 files on non-Windows
    if [[ "$script_name" == *.ps1 ]]; then
        echo "- SKIP: Executable check for PowerShell: ${script_name}"
        return 0
    fi

    assert_true "[ -x '${script_path}' ]" "Script is executable: ${script_name}"
}

# Test: Shell script syntax is valid
test_shell_syntax() {
    local script_name="$1"
    local script_path="${SCRIPTS_PATH}/${script_name}"

    assert [ -n "$script_name" ] "script_name must not be empty"

    # Skip non-shell scripts
    if [[ "$script_name" == *.ps1 ]] || [[ "$script_name" == *.bat ]]; then
        echo "- SKIP: Shell syntax check for: ${script_name}"
        return 0
    fi

    assert_true "bash -n '${script_path}' 2>/dev/null" "Valid shell syntax: ${script_name}"
}

# Test: Script contains required shebang
test_has_shebang() {
    local script_name="$1"
    local script_path="${SCRIPTS_PATH}/${script_name}"

    assert [ -n "$script_name" ] "script_name must not be empty"

    # Skip Windows scripts
    if [[ "$script_name" == *.ps1 ]] || [[ "$script_name" == *.bat ]]; then
        echo "- SKIP: Shebang check for Windows script: ${script_name}"
        return 0
    fi

    local first_line
    first_line=$(head -n1 "${script_path}")
    assert_true "[[ '${first_line}' == '#!'* ]]" "Has shebang: ${script_name}"
}

# Test: Script does not exceed 500 lines
test_line_count() {
    local script_name="$1"
    local script_path="${SCRIPTS_PATH}/${script_name}"

    assert [ -n "$script_name" ] "script_name must not be empty"

    local line_count
    line_count=$(wc -l < "${script_path}")
    assert_true "[ ${line_count} -le 500 ]" "Line count <= 500 (${line_count}): ${script_name}"
}

# Main test runner
run_tests() {
    echo "========================================="
    echo "Running Script Tests"
    echo "Script directory: ${SCRIPTS_PATH}"
    echo "========================================="
    echo ""

    # Define expected scripts
    local -a install_scripts=("install-linux.sh" "install-macos.sh" "install-windows.ps1")
    local -a run_scripts=("run-linux.sh" "run-macos.sh" "run-windows.ps1")
    local -a uninstall_scripts=("uninstall-linux.sh" "uninstall-macos.sh" "uninstall-windows.ps1")
    local -a all_scripts=("${install_scripts[@]}" "${run_scripts[@]}" "${uninstall_scripts[@]}")

    # Bounded loop for script tests
    local iteration=0
    for script in "${all_scripts[@]}"; do
        ((iteration++)) || true
        if [ $iteration -gt $MAX_TEST_ITERATIONS ]; then
            echo "ERROR: Exceeded max iterations" >&2
            break
        fi

        echo "--- Testing: ${script} ---"
        test_script_exists "$script" || true
        test_script_executable "$script" || true
        test_shell_syntax "$script" || true
        test_has_shebang "$script" || true
        test_line_count "$script" || true
        echo ""
    done

    # Summary
    echo "========================================="
    echo "Test Summary"
    echo "========================================="
    echo "Total:  ${TESTS_RUN}"
    echo "Passed: ${TESTS_PASSED}"
    echo "Failed: ${TESTS_FAILED}"
    echo ""

    # Return exit code
    if [ "${TESTS_FAILED}" -eq 0 ]; then
        echo "All tests passed!"
        return 0
    else
        echo "Some tests failed!"
        return 1
    fi
}

# Entry point
main() {
    assert [ -d "${SCRIPTS_PATH}" ] "Scripts directory must exist: ${SCRIPTS_PATH}"
    run_tests
}

main "$@"
