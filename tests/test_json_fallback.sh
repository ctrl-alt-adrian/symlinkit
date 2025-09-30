#!/usr/bin/env bash
# Test JSON fallback functionality when jq is not available

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

TEST_DIR="/tmp/symlinkit_json_fallback_test_$$"
SYMLINKIT="./symlinkit"

# Helper functions
print_test() {
    echo -e "${YELLOW}Testing: $1${RESET}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_contains() {
    local output="$1"
    local expected="$2"
    if [[ "$output" == *"$expected"* ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: Output doesn't contain '$expected'${RESET}"
        echo -e "  Actual output: '$output'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_valid_json_array() {
    local output="$1"
    # Check if it's a valid JSON array format (even without jq)
    if [[ "$output" =~ ^\[.*\]$ ]] && [[ "$output" == *"{"* ]] && [[ "$output" == *"}"* ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: Output is not valid JSON array format${RESET}"
        echo -e "  Output: '$output'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Setup test environment
setup_test_env() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"/{source,test_json}

    # Create test files and symlinks
    echo "test file" > "$TEST_DIR/source/test.txt"
    ln -sf "$TEST_DIR/source/test.txt" "$TEST_DIR/test_json/good_link"
    ln -sf "/nonexistent/path" "$TEST_DIR/test_json/broken_link"
    ln -sf "$TEST_DIR/source/test.txt" "$TEST_DIR/test_json/another_link"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Test JSON without jq
test_json_without_jq() {
    echo -e "${BLUE}Testing JSON fallback functionality (without jq)${RESET}"

    # Create a temporary function that overrides jq command to simulate it not being available
    # Use a different approach that doesn't rely on export -f
    local old_path="$PATH"
    mkdir -p "$TEST_DIR/fake_bin"
    cat > "$TEST_DIR/fake_bin/jq" << 'JQEOF'
#!/bin/bash
echo "jq: command not found" >&2
exit 127
JQEOF
    chmod +x "$TEST_DIR/fake_bin/jq"
    export PATH="$TEST_DIR/fake_bin:$PATH"

    print_test "JSON list mode fallback (without jq)"
    output=$("$SYMLINKIT" --json --list "$TEST_DIR/test_json" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" '"target"'
    assert_valid_json_array "$output"

    print_test "JSON broken mode fallback (without jq)"
    output=$("$SYMLINKIT" --json --broken "$TEST_DIR/test_json" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" '"target"'
    assert_contains "$output" "broken_link"
    assert_valid_json_array "$output"

    print_test "JSON count-only mode (without jq)"
    output=$("$SYMLINKIT" --json --count-only "$TEST_DIR/test_json" 2>&1)
    assert_contains "$output" '"directory"'
    assert_contains "$output" '"count"'
    assert_contains "$output" "test_json"

    print_test "Fallback comma separation"
    output=$("$SYMLINKIT" --json --list "$TEST_DIR/test_json" 2>&1)
    # Should have commas between JSON objects (except the last one)
    comma_count=$(echo "$output" | grep -o '},{' | wc -l)
    if [[ "$comma_count" -ge 1 ]]; then  # Should have at least 1 comma between objects
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: Expected comma-separated JSON objects${RESET}"
        echo -e "  Output: '$output'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Restore original PATH
    export PATH="$old_path"
}

# Test with jq available for comparison
test_json_with_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${YELLOW}Skipping jq comparison tests (jq not available)${RESET}"
        return 0
    fi

    echo -e "${BLUE}Testing JSON with jq (for comparison)${RESET}"

    print_test "JSON list mode with jq"
    output=$("$SYMLINKIT" --json --list "$TEST_DIR/test_json" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" '"target"'

    # Validate with jq
    print_test "Validate JSON with jq parser"
    if echo "$output" | jq . >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: Invalid JSON according to jq${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

print_test_summary() {
    echo -e "\n${BLUE}JSON Fallback Test Summary${RESET}"
    echo -e "Tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${RESET}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Failed: $TESTS_FAILED${RESET}"
        exit 1
    else
        echo -e "${GREEN}All JSON fallback tests passed!${RESET}"
        exit 0
    fi
}

# Main execution
main() {
    # Check if running on supported OS (macOS, Linux, WSL)
    case "$(uname -s)" in
        Linux*|Darwin*)
            # Supported OS
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo -e "${YELLOW}Skipping JSON fallback tests on Windows (not supported by symlinkit)${RESET}"
            exit 0
            ;;
        *)
            echo -e "${YELLOW}Skipping JSON fallback tests on unknown OS ($(uname -s))${RESET}"
            exit 0
            ;;
    esac

    if [[ ! -f "$SYMLINKIT" ]]; then
        echo -e "${RED}Error: symlinkit script not found${RESET}"
        exit 1
    fi

    chmod +x "$SYMLINKIT"
    setup_test_env
    trap cleanup_test_env EXIT

    test_json_without_jq
    test_json_with_jq

    print_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
