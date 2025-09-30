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
