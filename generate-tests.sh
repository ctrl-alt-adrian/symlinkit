#!/usr/bin/env bash
# Test generator for symlinkit
# This script generates all test files locally for running the test suite

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Show usage if help is requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo -e "${BLUE}🔧 Symlinkit Test Generator${RESET}"
    echo -e "${BLUE}==========================${RESET}\n"
    echo "Usage: $0"
    echo ""
    echo "Generates test files locally for the symlinkit project."
    echo ""
    echo "Generated files:"
    echo "  simple_test.sh           - Basic functionality tests"
    echo "  test_json_fallback.sh    - JSON functionality without jq"
    echo "  run_tests.sh             - Test runner with dependency checks"
    echo ""
    echo "After generation, run tests with:"
    echo "  ./run_tests.sh           - Run all tests"
    echo "  ./simple_test.sh         - Run basic tests only"
    echo "  ./test_json_fallback.sh  - Run JSON fallback tests only"
    echo ""
    echo "Requirements:"
    echo "  Required: fzf (for interactive functionality)"
    echo "  Optional: tree, jq (tests skip gracefully if missing)"
    echo ""
    echo "Supported OS: Linux, macOS (including WSL)"
    echo "Note: Tests are generated locally and not committed to git."
    exit 0
fi

echo -e "${BLUE}🔧 Symlinkit Test Generator${RESET}"
echo -e "${BLUE}==========================${RESET}\n"

# Check if we're in the right directory
if [[ ! -f "./symlinkit" ]]; then
    echo -e "${RED}❌ Error: symlinkit script not found${RESET}"
    echo -e "${YELLOW}Please run this script from the symlinkit project directory${RESET}"
    exit 1
fi

echo -e "${YELLOW}Generating test files...${RESET}\n"

# Generate simple_test.sh
echo -e "${BLUE}Creating simple_test.sh...${RESET}"
cat > simple_test.sh << 'EOF'
#!/usr/bin/env bash
# Simple test suite for symlinkit - focuses on basic functionality

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

SYMLINKIT="./symlinkit"
TEST_DIR="/tmp/symlinkit_simple_test_$$"

print_test() {
    echo -e "${YELLOW}Testing: $1${RESET}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_success() {
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    local output="$1"
    local expected="$2"
    if [[ "$output" == *"$expected"* ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL: Expected '$expected' in output${RESET}"
        echo -e "  Actual: '$output'"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

setup_test_env() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"/{source,dest,json_test}
    echo "test file" > "$TEST_DIR/source/file.txt"
    ln -sf "$TEST_DIR/source/file.txt" "$TEST_DIR/json_test/good_link"
    ln -sf "/nonexistent/path" "$TEST_DIR/json_test/broken_link"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

test_basic_commands() {
    echo -e "${BLUE}=== Testing Basic Commands ===${RESET}"

    print_test "Version flag"
    output=$("$SYMLINKIT" --version 2>&1)
    assert_contains "$output" "symlinkit"

    print_test "Help flag"
    output=$("$SYMLINKIT" --help 2>&1)
    assert_contains "$output" "Usage"
}

test_json_functionality() {
    echo -e "${BLUE}=== Testing JSON Functionality ===${RESET}"

    # Check if running on supported OS (macOS, Linux, WSL)
    case "$(uname -s)" in
        Linux*|Darwin*)
            # Supported OS
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo -e "${YELLOW}Skipping JSON tests on Windows (not supported by symlinkit)${RESET}"
            return 0
            ;;
        *)
            echo -e "${YELLOW}Skipping JSON tests on unknown OS ($(uname -s))${RESET}"
            return 0
            ;;
    esac

    print_test "JSON list mode"
    output=$("$SYMLINKIT" --json "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" '"target"'

    print_test "JSON broken mode"
    output=$("$SYMLINKIT" --json --broken "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" "broken_link"

    print_test "JSON count mode"
    output=$("$SYMLINKIT" --json --count-only "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" '"count"'
}

test_symlink_operations() {
    echo -e "${BLUE}=== Testing Symlink Operations ===${RESET}"

    print_test "Overwrite mode dry-run"
    output=$("$SYMLINKIT" --dry-run -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/test_link" 2>&1)
    assert_contains "$output" "Would"

    print_test "List mode"
    output=$("$SYMLINKIT" --list "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    print_test "Broken mode"
    output=$("$SYMLINKIT" --broken "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "broken_link"
}

print_summary() {
    echo -e "${BLUE}=== Test Summary ===${RESET}"
    echo -e "Tests run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${RESET}"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Failed: $TESTS_FAILED${RESET}"
        exit 1
    else
        echo -e "${GREEN}All tests passed!${RESET}"
        exit 0
    fi
}

main() {
    echo -e "${BLUE}Starting Simple Symlinkit Test Suite${RESET}"

    if [[ ! -f "$SYMLINKIT" ]]; then
        echo -e "${RED}Error: symlinkit not found${RESET}"
        exit 1
    fi

    chmod +x "$SYMLINKIT"
    setup_test_env
    trap cleanup_test_env EXIT

    test_basic_commands
    test_json_functionality
    test_symlink_operations

    print_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
EOF

chmod +x simple_test.sh
echo -e "${GREEN}✓ Created simple_test.sh${RESET}"

# Generate test_json_fallback.sh
echo -e "${BLUE}Creating test_json_fallback.sh...${RESET}"
cat > test_json_fallback.sh << 'EOF'
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
EOF

chmod +x test_json_fallback.sh
echo -e "${GREEN}✓ Created test_json_fallback.sh${RESET}"

# Generate run_tests.sh
echo -e "${BLUE}Creating run_tests.sh...${RESET}"
cat > run_tests.sh << 'EOF'
#!/usr/bin/env bash
# Test runner for symlinkit - runs all tests

set -euo pipefail

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

echo -e "${BLUE}🧪 Symlinkit Test Suite Runner${RESET}"
echo -e "${BLUE}==============================${RESET}\n"

# Check dependencies
check_dependencies() {
    local missing_deps=()

    if ! command -v fzf >/dev/null 2>&1; then
        missing_deps+=("fzf")
    fi

    # Check optional dependencies
    local optional_missing=()
    if ! command -v tree >/dev/null 2>&1; then
        optional_missing+=("tree")
    fi

    if ! command -v jq >/dev/null 2>&1; then
        optional_missing+=("jq")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        echo -e "${RED}❌ Missing required dependencies: ${missing_deps[*]}${RESET}"
        echo -e "${YELLOW}Please install the missing dependencies and try again.${RESET}"
        exit 1
    fi

    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⚠️  Optional dependencies missing: ${optional_missing[*]}${RESET}"
        echo -e "${YELLOW}Some tests will be skipped.${RESET}\n"
    fi
}

# Run individual test suite
run_test_suite() {
    local test_script="$1"
    local test_name="$2"

    echo -e "${BLUE}Running $test_name...${RESET}"

    if [[ ! -f "$test_script" ]]; then
        echo -e "${RED}❌ Test script not found: $test_script${RESET}"
        echo -e "${YELLOW}💡 Run './generate-tests.sh' first to create test files${RESET}"
        return 1
    fi

    if ! bash "$test_script"; then
        echo -e "${RED}❌ $test_name failed${RESET}"
        return 1
    else
        echo -e "${GREEN}✅ $test_name passed${RESET}"
        return 0
    fi
}

# Check OS compatibility
check_os_compatibility() {
    case "$(uname -s)" in
        Linux*|Darwin*)
            echo -e "${GREEN}✅ Running on supported OS: $(uname -s)${RESET}"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo -e "${YELLOW}⚠️  Running on Windows-like environment ($(uname -s))${RESET}"
            echo -e "${YELLOW}Some JSON tests will be skipped as they require macOS/Linux/WSL${RESET}"
            ;;
        *)
            echo -e "${YELLOW}⚠️  Running on unknown OS: $(uname -s)${RESET}"
            echo -e "${YELLOW}Some tests may be skipped due to OS compatibility${RESET}"
            ;;
    esac
    echo ""
}

# Main execution
main() {
    local exit_code=0

    # Check OS compatibility
    check_os_compatibility

    # Check if symlinkit exists
    if [[ ! -f "./symlinkit" ]]; then
        echo -e "${RED}❌ symlinkit script not found in current directory${RESET}"
        echo -e "${YELLOW}Please run this script from the symlinkit directory${RESET}"
        exit 1
    fi

    # Check dependencies
    check_dependencies

    echo -e "${BLUE}Starting test execution...${RESET}\n"

    # Run simple test first (most basic)
    if ! run_test_suite "./simple_test.sh" "Simple Tests"; then
        exit_code=1
    fi

    echo ""

    # Run JSON fallback tests
    if ! run_test_suite "./test_json_fallback.sh" "JSON Fallback Tests"; then
        exit_code=1
    fi

    echo ""

    # Final summary
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed successfully!${RESET}"
        echo -e "${GREEN}symlinkit is working correctly.${RESET}"
    else
        echo -e "${RED}💥 Some tests failed.${RESET}"
        echo -e "${YELLOW}Please check the output above for details.${RESET}"
    fi

    exit $exit_code
}

# Show usage if help is requested
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0"
    echo ""
    echo "Runs the complete symlinkit test suite including:"
    echo "  - Simple tests (simple_test.sh)"
    echo "  - JSON fallback tests (test_json_fallback.sh)"
    echo ""
    echo "Dependencies:"
    echo "  Required: fzf"
    echo "  Optional: tree, jq (some tests skipped if missing)"
    echo ""
    echo "Run from the symlinkit project directory."
    echo "Generate test files first with: ./generate-tests.sh"
    exit 0
fi

# Run main
main "$@"
EOF

chmod +x run_tests.sh
echo -e "${GREEN}✓ Created run_tests.sh${RESET}"

echo -e "\n${GREEN}✅ Test files generated successfully!${RESET}"
echo -e "\n${BLUE}Usage:${RESET}"
echo -e "  ${YELLOW}./run_tests.sh${RESET}     - Run all tests"
echo -e "  ${YELLOW}./simple_test.sh${RESET}   - Run basic functionality tests"
echo -e "  ${YELLOW}./test_json_fallback.sh${RESET} - Run JSON fallback tests"
echo -e "\n${BLUE}Dependencies:${RESET}"
echo -e "  Required: fzf"
echo -e "  Optional: tree, jq (some tests skipped if missing)"