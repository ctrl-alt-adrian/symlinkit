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
    CURRENT_TEST="$1"
    echo -e "${YELLOW}Testing: $1${RESET}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

pass() {
    echo -e "${GREEN}✓ PASS${RESET}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}✗ FAIL: $1${RESET}"
    echo -e "  ${RED}Test:${RESET} $CURRENT_TEST"
    echo -e "  ${RED}Location:${RESET} Line $(caller | awk '{print $1}')"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_success() {
    local exit_code=$?
    if [[ $exit_code -eq 0 ]]; then
        pass
    else
        fail "Command failed with exit code $exit_code"
    fi
}

assert_contains() {
    local output="$1"
    local expected="$2"
    if [[ "$output" == *"$expected"* ]]; then
        pass
    else
        echo -e "${RED}✗ FAIL: Expected '$expected' in output${RESET}"
        echo -e "  ${RED}Test:${RESET} $CURRENT_TEST"
        echo -e "  ${RED}Expected:${RESET} '$expected'"
        echo -e "  ${RED}Actual output:${RESET}"
        echo "$output" | head -10 | sed 's/^/    /'
        if [[ $(echo "$output" | wc -l) -gt 10 ]]; then
            echo "    ... (output truncated)"
        fi
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

    print_test "Create mode dry-run"
    output=$("$SYMLINKIT" --dry-run -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/new_link" 2>&1)
    assert_contains "$output" "Would create"

    print_test "Create mode (actual)"
    "$SYMLINKIT" -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/actual_link" >/dev/null 2>&1
    [[ -L "$TEST_DIR/dest/actual_link/file.txt" ]] && pass || fail "Link not created"

    print_test "Create mode (fail if exists)"
    output=$("$SYMLINKIT" -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/actual_link" 2>&1 || true)
    assert_contains "$output" "exists"

    print_test "Overwrite mode dry-run"
    output=$("$SYMLINKIT" --dry-run -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/test_link" 2>&1)
    assert_contains "$output" "Would"

    print_test "Overwrite mode (actual)"
    mkdir -p "$TEST_DIR/dest/temp_target"
    echo "temp" > "$TEST_DIR/dest/temp_target/oldfile"
    "$SYMLINKIT" -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/temp_target" >/dev/null 2>&1
    [[ -L "$TEST_DIR/dest/temp_target/file.txt" ]] && pass || fail "Overwrite failed"

    print_test "Merge mode dry-run"
    output=$("$SYMLINKIT" --dry-run -m "$TEST_DIR/source" "$TEST_DIR/dest/merge_test" 2>&1)
    assert_contains "$output" "Would"

    print_test "Merge mode (actual)"
    echo "s" | "$SYMLINKIT" -m "$TEST_DIR/source" "$TEST_DIR/dest/merge_actual" >/dev/null 2>&1
    [[ -d "$TEST_DIR/dest/merge_actual" ]] && pass || fail "Merge failed"

    print_test "Delete mode dry-run"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/delete_test"
    output=$("$SYMLINKIT" --dry-run -d "$TEST_DIR/dest/delete_test" 2>&1)
    assert_contains "$output" "Would delete"
    [[ -L "$TEST_DIR/dest/delete_test" ]] && pass || fail "Link was deleted during dry-run"

    print_test "Delete mode (actual)"
    "$SYMLINKIT" -d "$TEST_DIR/dest/delete_test" >/dev/null 2>&1
    [[ ! -L "$TEST_DIR/dest/delete_test" ]] && pass || fail "Link not deleted"

    print_test "Delete preserves source file"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/preserve_test"
    "$SYMLINKIT" -d "$TEST_DIR/dest/preserve_test" >/dev/null 2>&1
    [[ -f "$TEST_DIR/source/file.txt" ]] && pass || fail "Source file was deleted"

    print_test "Recursive delete dry-run"
    mkdir -p "$TEST_DIR/dest/rec_delete"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link1"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link2"
    output=$(echo "d" | "$SYMLINKIT" --dry-run -dr "$TEST_DIR/dest/rec_delete" 2>&1)
    assert_contains "$output" "Would delete"
    [[ -L "$TEST_DIR/dest/rec_delete/link1" ]] && pass || fail "Link deleted during dry-run"

    print_test "Recursive delete dry-run with [a]ll"
    output=$(echo "a" | "$SYMLINKIT" --dry-run -dr "$TEST_DIR/dest/rec_delete" 2>&1)
    assert_contains "$output" "Would delete (all)"
    [[ -L "$TEST_DIR/dest/rec_delete/link1" ]] && pass || fail "Link deleted during dry-run"

    print_test "Recursive delete (skip all)"
    echo "s" | "$SYMLINKIT" -dr "$TEST_DIR/dest/rec_delete" >/dev/null 2>&1
    [[ -L "$TEST_DIR/dest/rec_delete/link1" ]] && pass || fail "Link was deleted when skipped"

    print_test "Recursive delete (delete all)"
    # Recreate links for this test since previous test skipped them
    rm -rf "$TEST_DIR/dest/rec_delete"
    mkdir -p "$TEST_DIR/dest/rec_delete"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link1"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link2"
    echo "a" | "$SYMLINKIT" -dr "$TEST_DIR/dest/rec_delete" >/dev/null 2>&1
    [[ ! -L "$TEST_DIR/dest/rec_delete/link1" ]] && [[ ! -L "$TEST_DIR/dest/rec_delete/link2" ]] && pass || fail "Links not deleted"

    print_test "Recursive delete preserves source files"
    [[ -f "$TEST_DIR/source/file.txt" ]] && pass || fail "Source file was deleted"

    print_test "Recursive delete with [a]ll option"
    mkdir -p "$TEST_DIR/dest/rec_all"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_all/link1"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_all/link2"
    echo "a" | "$SYMLINKIT" -dr "$TEST_DIR/dest/rec_all" >/dev/null 2>&1
    [[ ! -L "$TEST_DIR/dest/rec_all/link1" ]] && [[ ! -L "$TEST_DIR/dest/rec_all/link2" ]] && pass || fail "All links not deleted"

    print_test "Flag chaining: -cr (create recursive)"
    echo "s" | "$SYMLINKIT" -cr "$TEST_DIR/source" "$TEST_DIR/dest/cr_test" >/dev/null 2>&1
    [[ -d "$TEST_DIR/dest/cr_test" ]] && pass || fail "Create recursive failed"

    print_test "Flag chaining: -or (overwrite recursive)"
    mkdir -p "$TEST_DIR/dest/or_test"
    echo "s" | "$SYMLINKIT" -or "$TEST_DIR/source" "$TEST_DIR/dest/or_test" >/dev/null 2>&1
    [[ -d "$TEST_DIR/dest/or_test" ]] && pass || fail "Overwrite recursive failed"

    print_test "List mode"
    output=$("$SYMLINKIT" --list "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    print_test "List-verbose mode"
    output=$("$SYMLINKIT" --list-verbose "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    print_test "Broken mode"
    output=$("$SYMLINKIT" --broken "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "broken_link"

    print_test "Fix-broken with [a]ll delete option"
    mkdir -p "$TEST_DIR/fix_test"
    ln -s "/nonexistent1" "$TEST_DIR/fix_test/broken1"
    ln -s "/nonexistent2" "$TEST_DIR/fix_test/broken2"
    echo "a" | "$SYMLINKIT" --fix-broken "$TEST_DIR/fix_test" >/dev/null 2>&1
    [[ ! -L "$TEST_DIR/fix_test/broken1" ]] && pass || fail "Broken links not deleted"

    print_test "Fix-broken dry-run with [a]ll delete"
    ln -s "/nonexistent3" "$TEST_DIR/fix_test/broken3"
    output=$(echo "a" | "$SYMLINKIT" --dry-run --fix-broken "$TEST_DIR/fix_test" 2>&1)
    assert_contains "$output" "Would delete"
    [[ -L "$TEST_DIR/fix_test/broken3" ]] && pass || fail "Link deleted during dry-run"

    print_test "List with no symlinks (no false positive)"
    mkdir -p "$TEST_DIR/empty_dir"
    output=$("$SYMLINKIT" --list "$TEST_DIR/empty_dir" 2>&1)
    assert_contains "$output" "No symlinks"
}

test_tree_operations() {
    echo -e "${BLUE}=== Testing Tree Operations ===${RESET}"

    print_test "Tree mode"
    if command -v tree >/dev/null 2>&1; then
        output=$("$SYMLINKIT" --tree "$TEST_DIR/json_test" 2>&1 || true)
        assert_contains "$output" "good_link"
    else
        echo -e "${YELLOW}⊘ SKIP (tree not installed)${RESET}"
        TESTS_RUN=$((TESTS_RUN + 1))
    fi

    print_test "Tree-verbose mode"
    if command -v tree >/dev/null 2>&1; then
        output=$("$SYMLINKIT" --tree-verbose "$TEST_DIR/json_test" 2>&1 || true)
        assert_contains "$output" "good_link"
    else
        echo -e "${YELLOW}⊘ SKIP (tree not installed)${RESET}"
        TESTS_RUN=$((TESTS_RUN + 1))
    fi
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
    test_tree_operations

    print_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
