# Testing Framework Guide

This comprehensive guide explains symlinkit's testing system, how to run tests, add new tests, and ensure your contributions meet quality standards.

## 📋 Table of Contents
- [Overview](#overview)
- [Getting Started with Tests](#getting-started-with-tests)
- [Test Architecture](#test-architecture)
- [Adding New Tests](#adding-new-tests)
- [Test Categories](#test-categories)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

symlinkit uses a **generated testing system** that keeps the repository clean while providing comprehensive test coverage. Tests are generated locally when needed, ensuring thorough validation without bloating the codebase.

### Key Principles
- **🚀 No Committed Test Files** - Tests are generated locally via `generate-tests.sh`
- **🧪 Comprehensive Coverage** - Tests cover all major functionality and edge cases
- **🔄 Cross-platform Support** - Tests work on Linux, macOS, and WSL
- **⚡ Graceful Degradation** - Missing optional dependencies don't break the test suite
- **📊 Clear Reporting** - Colored output with detailed pass/fail information

---

## 🚀 Getting Started with Tests

### Quick Start
```bash
# 1. Generate test files
./generate-tests.sh

# 2. Make test scripts executable (if needed)
chmod +x *.sh

# 3. Run all tests
./run_tests.sh

# 4. View help for any script
./generate-tests.sh --help
./run_tests.sh --help
```

### Individual Test Suites
```bash
# Run basic functionality tests only
./simple_test.sh

# Run JSON fallback tests only
./test_json_fallback.sh

# Get help for any test suite
./simple_test.sh --help  # (if available)
```

---

## 🏗️ Test Architecture

### Core Components

#### 1. Test Generator (`generate-tests.sh`)
- **Purpose**: Creates all test files locally
- **Generated Files**:
  - `simple_test.sh` - Basic functionality tests
  - `test_json_fallback.sh` - JSON functionality without jq
  - `run_tests.sh` - Main test runner with dependency management

#### 2. Test Runner (`run_tests.sh`)
- **Dependency checking**: Validates required and optional dependencies
- **OS compatibility**: Checks platform support
- **Orchestration**: Runs all test suites in order
- **Reporting**: Aggregates results and provides summary

#### 3. Test Suites

##### Simple Tests (`simple_test.sh`)
```bash
# Test structure
test_basic_commands()      # --version, --help, flag parsing
test_json_functionality()  # Basic JSON output modes
test_symlink_operations()  # Core symlink creation and inspection
```

##### JSON Fallback Tests (`test_json_fallback.sh`)
```bash
# Test structure
test_json_without_jq()     # JSON formatting without jq dependency
test_json_with_jq()        # Validation with jq when available
```

### Test Framework Functions

#### Core Testing Functions
```bash
# Test execution
print_test("Test description")           # Announce test start
assert_success()                         # Check last command succeeded
assert_contains(output, expected)        # Verify string containment
assert_valid_json_array(output)         # Validate JSON format

# Environment management
setup_test_env()                         # Create test directories/files
cleanup_test_env()                       # Remove test artifacts
```

#### Test Environment Structure
```bash
TEST_DIR="/tmp/symlinkit_test_$$"        # Unique per test run
├── source/                              # Source files for linking
│   └── file.txt
├── dest/                                # Destination directory
├── json_test/                           # JSON test fixtures
│   ├── good_link -> ../source/file.txt
│   └── broken_link -> /nonexistent/path
```

---

## ➕ Adding New Tests

### Step 1: Understand the Test Structure

First, examine the existing test generation system:

```bash
# Look at the test generator
cat generate-tests.sh | head -50

# See how existing tests are structured
./generate-tests.sh && head -20 simple_test.sh
```

### Step 2: Choose the Right Test Suite

- **Basic functionality** → Add to `simple_test.sh` generation
- **JSON-related features** → Add to `test_json_fallback.sh` generation
- **New major feature** → Create new test file in generator

### Step 3: Modify the Generator

Edit `generate-tests.sh` and add your test to the appropriate section:

```bash
# Example: Adding a new test to simple_test.sh
# Find this section in generate-tests.sh:

test_symlink_operations() {
    echo -e "${BLUE}=== Testing Symlink Operations ===${RESET}"

    # Add your new test here:
    print_test "Your new test description"
    output=$("$SYMLINKIT" --your-new-flag "$TEST_DIR/some_path" 2>&1)
    assert_contains "$output" "expected_string"

    # Existing tests continue...
    print_test "Overwrite mode dry-run"
    output=$("$SYMLINKIT" --dry-run -o "$TEST_DIR/source/file.txt" "$TEST_DIR/dest/test_link" 2>&1)
    assert_contains "$output" "Would"
}
```

### Step 4: Test Your Changes

```bash
# 1. Regenerate tests with your changes
./generate-tests.sh

# 2. Run the specific test suite
./simple_test.sh  # or whichever you modified

# 3. Run full test suite
./run_tests.sh

# 4. Verify your test fails when it should
# Modify symlinkit to break your feature, then run tests
```

### Step 5: Example - Adding fzf Flag Tests

Here's how you would add tests for the new `--fzf` and `--no-fzf` flags:

```bash
# In generate-tests.sh, add to the simple_test.sh generation:

test_fzf_flags() {
    echo -e "${BLUE}=== Testing fzf Flag Controls ===${RESET}"

    print_test "--fzf flag with fzf available"
    if command -v fzf >/dev/null 2>&1; then
        # Test should succeed when fzf is available
        output=$("$SYMLINKIT" --fzf --version 2>&1)
        assert_success
    else
        # Test should fail when fzf is not available
        output=$("$SYMLINKIT" --fzf --version 2>&1)
        if [[ $? -ne 0 ]]; then
            echo -e "${GREEN}✓ PASS (correctly failed without fzf)${RESET}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "${RED}✗ FAIL (should have failed without fzf)${RESET}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    fi

    print_test "--no-fzf flag functionality"
    output=$("$SYMLINKIT" --no-fzf --list "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    print_test "Conflicting flags detection"
    output=$("$SYMLINKIT" --fzf --no-fzf 2>&1)
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS (correctly rejected conflicting flags)${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL (should reject conflicting flags)${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

Then add the function call to the main execution:

```bash
# In the main() function:
test_basic_commands
test_json_functionality
test_symlink_operations
test_fzf_flags  # <-- Add this line
```

---

## 🧪 Test Categories

### 1. Core Functionality Tests
**Location**: `simple_test.sh`
**Purpose**: Validate basic operations work correctly

```bash
# Examples of what to test:
- Flag parsing (--help, --version, invalid flags)
- Basic symlink operations (overwrite, merge modes)
- Interactive mode defaults
- Error handling for invalid inputs
```

### 2. JSON & Output Tests
**Location**: `test_json_fallback.sh`
**Purpose**: Ensure output formats work with/without dependencies

```bash
# Examples of what to test:
- JSON output with jq available
- JSON fallback formatting without jq
- JSON validation and structure
- Output consistency across modes
```

### 3. Integration Tests
**Location**: Both test suites
**Purpose**: Verify features work together correctly

```bash
# Examples of what to test:
- Dry-run modes with different flags
- JSON output combined with inspection modes
- Flag interactions and conflicts
- Cross-platform path handling
```

### 4. Edge Case Tests
**Location**: Appropriate test suite
**Purpose**: Handle unusual scenarios gracefully

```bash
# Examples of what to test:
- Missing dependencies
- Permission errors
- Invalid paths
- Large directory structures
- Broken symlinks in various states
```

---

## 📝 Best Practices

### Writing Effective Tests

#### 1. Test Structure
```bash
test_your_feature() {
    echo -e "${BLUE}=== Testing Your Feature ===${RESET}"

    # Setup (if needed)
    mkdir -p "$TEST_DIR/feature_test"

    # Test 1: Normal case
    print_test "Feature works in normal case"
    output=$("$SYMLINKIT" --your-flag normal_input 2>&1)
    assert_contains "$output" "expected_output"

    # Test 2: Edge case
    print_test "Feature handles edge case"
    output=$("$SYMLINKIT" --your-flag edge_case_input 2>&1)
    assert_success

    # Test 3: Error case
    print_test "Feature rejects invalid input"
    output=$("$SYMLINKIT" --your-flag invalid_input 2>&1)
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS (correctly failed)${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL (should have failed)${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

#### 2. Test Organization
- **Group related tests** in the same function
- **Use descriptive names** for test functions and descriptions
- **Test both success and failure cases**
- **Clean up after tests** (handled by trap in framework)

#### 3. Cross-Platform Considerations
```bash
# Check OS compatibility
case "$(uname -s)" in
    Linux*|Darwin*)
        # Run test
        ;;
    CYGWIN*|MINGW*|MSYS*)
        echo -e "${YELLOW}Skipping test on Windows${RESET}"
        return 0
        ;;
    *)
        echo -e "${YELLOW}Skipping test on unknown OS${RESET}"
        return 0
        ;;
esac
```

#### 4. Dependency Handling
```bash
# Optional dependency tests
if ! command -v optional_tool >/dev/null 2>&1; then
    echo -e "${YELLOW}Skipping tests requiring optional_tool${RESET}"
    return 0
fi
```

### Testing New Features Checklist

✅ **Basic functionality** - Does the feature work as intended?
✅ **Error handling** - Does it fail gracefully with invalid input?
✅ **Flag interactions** - Does it work with other flags?
✅ **Output format** - Is output consistent with existing patterns?
✅ **Cross-platform** - Works on Linux, macOS, WSL?
✅ **Dependencies** - Handles missing optional dependencies?
✅ **Edge cases** - Handles unusual but valid scenarios?
✅ **Performance** - Reasonable performance with large inputs?

---

## 🐛 Troubleshooting

### Common Issues

#### Tests Not Running
```bash
# Problem: Command not found
chmod +x generate-tests.sh run_tests.sh

# Problem: Tests not generated
./generate-tests.sh
ls -la *.sh

# Problem: Wrong directory
ls symlinkit  # Should exist
pwd           # Should be in symlinkit directory
```

#### Test Failures
```bash
# Debug failing tests
./simple_test.sh | grep "FAIL"

# Run with verbose output
set -x
./simple_test.sh
set +x

# Check specific functionality manually
./symlinkit --version
./symlinkit --help
```

#### Missing Dependencies
```bash
# Check dependency status
./run_tests.sh | head -20

# Install missing required dependencies
# Linux:
sudo apt-get install fzf realpath
# macOS:
brew install fzf coreutils

# Optional dependencies (gracefully skipped if missing)
# Linux:
sudo apt-get install tree jq
# macOS:
brew install tree jq
```

### Debugging Test Framework Issues

#### Test Environment Problems
```bash
# Check test directory creation
TEST_DIR="/tmp/symlinkit_test_$$"
echo "Test dir: $TEST_DIR"
ls -la "$TEST_DIR" 2>/dev/null || echo "Test dir not created"

# Verify test fixtures
ls -la "$TEST_DIR/json_test/"
ls -la "$TEST_DIR/source/"
```

#### Output Comparison Issues
```bash
# Debug assert_contains failures
output="actual output here"
expected="expected string"
echo "Output: '$output'"
echo "Expected: '$expected'"
[[ "$output" == *"$expected"* ]] && echo "Match" || echo "No match"
```

---

## 🚀 Advanced Testing Scenarios

### Testing Interactive Features
```bash
# Test non-interactive modes (recommended for automated tests)
test_interactive_fallback() {
    print_test "Non-interactive flag behavior"

    # Test --no-fzf with directory argument (should not prompt)
    output=$("$SYMLINKIT" --no-fzf --list "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    # Avoid testing actual interactive prompts in automated tests
    # Interactive testing should be done manually
}
```

### Performance Testing
```bash
test_performance_basics() {
    print_test "Performance with depth limits"

    # Create nested structure
    mkdir -p "$TEST_DIR/deep/"{1..5}/{a,b,c}

    # Test with depth limit
    timeout 10s "$SYMLINKIT" --depth 2 --count-only "$TEST_DIR/deep" >/dev/null
    assert_success
}
```

### Integration Testing
```bash
test_flag_combinations() {
    print_test "Multiple flags work together"

    output=$("$SYMLINKIT" --json --broken --sort path "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" '"path"'
    assert_contains "$output" "broken_link"

    print_test "Conflicting flags handled properly"
    output=$("$SYMLINKIT" --fzf --no-fzf 2>&1)
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS (correctly rejected)${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL (should reject conflicting flags)${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

---

## 📊 Test Reporting and CI Integration

### Understanding Test Output

#### Success Output
```bash
🧪 Symlinkit Test Suite Runner
==============================

✅ Running on supported OS: Linux
Starting test execution...

Running Simple Tests...
Testing: Version flag
✓ PASS
Testing: Help flag
✓ PASS
...
✅ Simple Tests passed

Running JSON Fallback Tests...
...
✅ JSON Fallback Tests passed

🎉 All tests passed successfully!
symlinkit is working correctly.
```

#### Failure Output
```bash
Testing: Your new feature
✗ FAIL: Expected 'expected_string' in output
  Actual: 'actual output without expected string'

❌ Simple Tests failed
💥 Some tests failed.
Please check the output above for details.
```

### Integrating with CI/CD
```bash
#!/bin/bash
# CI/CD integration script

set -euo pipefail

echo "Setting up symlinkit tests..."
cd symlinkit/

# Generate tests
./generate-tests.sh

# Run tests with exit code handling
if ./run_tests.sh; then
    echo "✅ All tests passed"
    exit 0
else
    echo "❌ Tests failed"
    exit 1
fi
```

---

**Remember**: Every contribution to symlinkit must include appropriate tests. This ensures reliability and prevents regressions. When in doubt, add more tests rather than fewer!

*For more information on contributing, see the [[Contributing]] guide.*