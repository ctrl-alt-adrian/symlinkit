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

strip_ansi() {
    # remove ANSI escape sequences
    sed -r "s/\x1B\[[0-9;]*[JKmsu]//g"
}

assert_contains() {
    local output="$1"
    local expected="$2"
    local clean_output
    clean_output=$(echo "$output" | strip_ansi)

    if [[ "$clean_output" == *"$expected"* ]]; then
        pass
    else
        echo -e "${RED}✗ FAIL: Expected '$expected' in output${RESET}"
        echo -e "  ${RED}Test:${RESET} $CURRENT_TEST"
        echo -e "  ${RED}Expected:${RESET} '$expected'"
        echo -e "  ${RED}Actual output:${RESET}"
        echo "$clean_output" | head -10 | sed 's/^/    /'
        if [[ $(echo "$clean_output" | wc -l) -gt 10 ]]; then
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
    output=$( ( "$SYMLINKIT" --version ) 2>&1 || true)
    assert_contains "$output" "symlinkit"

    print_test "Help flag"
    output=$( ( "$SYMLINKIT" --help ) 2>&1 || true)
    assert_contains "$output" "Usage"

    print_test "Invalid flag combination -cd"
    output=$( ( "$SYMLINKIT" -cd ) 2>&1 || true)
    assert_contains "$output" "Invalid flag combination"

    print_test "Invalid flag combination -md"
    output=$( ( "$SYMLINKIT" -md ) 2>&1 || true)
    assert_contains "$output" "Invalid flag combination"

    print_test "Invalid flag combination -co"
    output=$( ( "$SYMLINKIT" -co ) 2>&1 || true)
    assert_contains "$output" "Invalid flag combination"
}

test_symlink_operations() {
    echo -e "${BLUE}=== Testing Symlink Operations ===${RESET}"

    print_test "Create mode dry-run"
    output=$( ( "$SYMLINKIT" --dry-run -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/new_link" ) 2>&1 || true)
    assert_contains "$output" "Would create"

    print_test "Create mode (actual)"
    ( "$SYMLINKIT" -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/actual_link" ) >/dev/null 2>&1 || true
    if [[ -L "$TEST_DIR/dest/actual_link" ]]; then
        pass
    else
        fail "Link not created"
    fi

    print_test "Create mode (fail if exists)"
    output=$( ( "$SYMLINKIT" -c "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/actual_link" ) 2>&1 || true)
    assert_contains "$output" "exists"

    print_test "Require operation flag with source path"
    output=$( ( "$SYMLINKIT" "$TEST_DIR/source" ) 2>&1 || true)
    assert_contains "$output" "No operation specified"

    print_test "Overwrite mode dry-run"
    output=$( ( "$SYMLINKIT" --dry-run -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/test_link" ) 2>&1 || true)
    assert_contains "$output" "Would"

    print_test "Overwrite mode (actual)"
    mkdir -p "$TEST_DIR/dest/temp_target"
    echo "temp" > "$TEST_DIR/dest/temp_target/oldfile"
    ( "$SYMLINKIT" -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/temp_target" ) >/dev/null 2>&1 || true
    if [[ -L "$TEST_DIR/dest/temp_target/file.txt" ]]; then
        pass
    else
        fail "Overwrite failed"
    fi

    print_test "Merge mode dry-run"
    output=$( ( "$SYMLINKIT" --dry-run -m "$TEST_DIR/source" "$TEST_DIR/dest/merge_test" ) 2>&1 || true)
    assert_contains "$output" "Would"

    print_test "Merge mode (actual)"
    echo "s" | ( "$SYMLINKIT" -m "$TEST_DIR/source" "$TEST_DIR/dest/merge_actual" ) >/dev/null 2>&1 || true
    if [[ -d "$TEST_DIR/dest/merge_actual" ]]; then
        pass
    else
        fail "Merge failed"
    fi

    print_test "Delete mode dry-run"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/delete_test"
    output=$( ( "$SYMLINKIT" --dry-run -d "$TEST_DIR/dest/delete_test" ) 2>&1 || true)
    assert_contains "$output" "Would delete"
    if [[ -L "$TEST_DIR/dest/delete_test" ]]; then
        pass
    else
        fail "Link was deleted during dry-run"
    fi

    print_test "Delete mode (actual)"
    ( "$SYMLINKIT" -d "$TEST_DIR/dest/delete_test" ) >/dev/null 2>&1 || true
    if [[ ! -L "$TEST_DIR/dest/delete_test" ]]; then
        pass
    else
        fail "Link not deleted"
    fi

    print_test "Delete preserves source file"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/preserve_test"
    ( "$SYMLINKIT" -d "$TEST_DIR/dest/preserve_test" ) >/dev/null 2>&1 || true
    if [[ -f "$TEST_DIR/source/file.txt" ]]; then
        pass
    else
        fail "Source file was deleted"
    fi

    print_test "Recursive delete dry-run"
    mkdir -p "$TEST_DIR/dest/rec_delete"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link1"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link2"
    output=$(echo "d" | ( "$SYMLINKIT" --dry-run -dr "$TEST_DIR/dest/rec_delete" ) 2>&1 || true)
    assert_contains "$output" "Would delete"
    if [[ -L "$TEST_DIR/dest/rec_delete/link1" ]]; then
        pass
    else
        fail "Link deleted during dry-run"
    fi

    print_test "Recursive delete dry-run with [a]ll"
    output=$(echo "a" | ( "$SYMLINKIT" --dry-run -dr "$TEST_DIR/dest/rec_delete" ) 2>&1 || true)
    assert_contains "$output" "Would delete (all)"
    if [[ -L "$TEST_DIR/dest/rec_delete/link1" ]]; then
        pass
    else
        fail "Link deleted during dry-run"
    fi

    print_test "Recursive delete (skip all)"
    echo "s" | ( "$SYMLINKIT" -dr "$TEST_DIR/dest/rec_delete" ) >/dev/null 2>&1 || true
    if [[ -L "$TEST_DIR/dest/rec_delete/link1" ]]; then
        pass
    else
        fail "Link was deleted when skipped"
    fi

    print_test "Recursive delete (delete all)"
    rm -rf "$TEST_DIR/dest/rec_delete"
    mkdir -p "$TEST_DIR/dest/rec_delete"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link1"
    ln -s "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/rec_delete/link2"
    echo "a" | ( "$SYMLINKIT" -dr "$TEST_DIR/dest/rec_delete" ) >/dev/null 2>&1 || true
    if [[ ! -L "$TEST_DIR/dest/rec_delete/link1" ]] && [[ ! -L "$TEST_DIR/dest/rec_delete/link2" ]]; then
        pass
    else
        fail "Links not deleted"
    fi

    print_test "Recursive delete preserves source files"
    if [[ -f "$TEST_DIR/source/file.txt" ]]; then
        pass
    else
        fail "Source file was deleted"
    fi

    print_test "Flag chaining: -cr (create recursive)"
    echo "s" | ( "$SYMLINKIT" -cr "$TEST_DIR/source" "$TEST_DIR/dest/cr_test" ) >/dev/null 2>&1 || true
    if [[ -d "$TEST_DIR/dest/cr_test" ]]; then
        pass
    else
        fail "Create recursive failed"
    fi

    print_test "Flag chaining: -or (overwrite recursive)"
    mkdir -p "$TEST_DIR/dest/or_test"
    echo "s" | ( "$SYMLINKIT" -or "$TEST_DIR/source" "$TEST_DIR/dest/or_test" ) >/dev/null 2>&1 || true
    if [[ -d "$TEST_DIR/dest/or_test" ]]; then
        pass
    else
        fail "Overwrite recursive failed"
    fi

    print_test "List mode"
    output=$( ( "$SYMLINKIT" --list "$TEST_DIR/json_test" ) 2>&1 || true)
    assert_contains "$output" "good_link"

    print_test "Broken mode"
    output=$( ( "$SYMLINKIT" --broken "$TEST_DIR/json_test" ) 2>&1 || true)
    assert_contains "$output" "broken_link"

    print_test "Fix-broken with [a]ll delete option"
    mkdir -p "$TEST_DIR/fix_test"
    ln -s "/nonexistent1" "$TEST_DIR/fix_test/broken1"
    ln -s "/nonexistent2" "$TEST_DIR/fix_test/broken2"
    echo "a" | ( "$SYMLINKIT" --fix-broken "$TEST_DIR/fix_test" ) >/dev/null 2>&1 || true
    if [[ ! -L "$TEST_DIR/fix_test/broken1" ]]; then
        pass
    else
        fail "Broken links not deleted"
    fi

    print_test "Fix-broken dry-run with [a]ll delete"
    ln -s "/nonexistent3" "$TEST_DIR/fix_test/broken3"
    output=$(echo "a" | ( "$SYMLINKIT" --dry-run --fix-broken "$TEST_DIR/fix_test" ) 2>&1 || true)
    assert_contains "$output" "Would delete"
    if [[ -L "$TEST_DIR/fix_test/broken3" ]]; then
        pass
    else
        fail "Link deleted during dry-run"
    fi

    print_test "List with no symlinks (no false positive)"
    mkdir -p "$TEST_DIR/empty_dir"
    output=$( ( "$SYMLINKIT" --list "$TEST_DIR/empty_dir" ) 2>&1 || true)
    assert_contains "$output" "No symlinks"
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
    echo -e "${BLUE}Starting Simple Symlinkit Test Suite (v2.0)${RESET}"

    if [[ ! -f "$SYMLINKIT" ]]; then
        echo -e "${RED}Error: symlinkit not found${RESET}"
        exit 1
    fi

    chmod +x "$SYMLINKIT"
    setup_test_env
    trap cleanup_test_env EXIT

    test_basic_commands
    test_symlink_operations

    print_summary
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

