# Contributing Guidelines

Welcome to symlinkit! We're excited that you want to contribute. This guide outlines our contribution process, requirements, and how to ensure your contributions meet our quality standards.

## 🚨 **MANDATORY REQUIREMENT: ALL CONTRIBUTIONS MUST INCLUDE TESTS**

**NO PULL REQUESTS WILL BE APPROVED WITHOUT APPROPRIATE TESTS.**

This policy ensures symlinkit remains reliable, prevents regressions, and maintains high code quality.

---

## 📋 Table of Contents
- [Quick Start for Contributors](#quick-start-for-contributors)
- [Contribution Types](#contribution-types)
- [Development Workflow](#development-workflow)
- [Testing Requirements](#testing-requirements-mandatory)
- [Code Quality Standards](#code-quality-standards)
- [Pull Request Process](#pull-request-process)
- [Getting Help](#getting-help)

---

## 🚀 Quick Start for Contributors

### 1. Environment Setup
```bash
# Fork and clone the repository
git clone https://github.com/YOUR-USERNAME/symlinkit.git
cd symlinkit

# Make symlinkit executable
chmod +x symlinkit

# Generate and run tests to verify setup
./generate-tests.sh
./run_tests.sh
```

### 2. Before Making Changes
```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Ensure tests pass before starting
./run_tests.sh
```

### 3. After Making Changes
```bash
# Add tests for your changes (MANDATORY)
# See "Adding Tests" section below

# Regenerate and run all tests
./generate-tests.sh
./run_tests.sh

# Ensure all tests pass before submitting
```

---

## 🎯 Contribution Types

### 🐛 Bug Fixes
**Test Requirements**:
- ✅ Test that reproduces the original bug (should fail before fix)
- ✅ Test that verifies the bug is fixed (should pass after fix)
- ✅ Regression test to prevent the bug from reoccurring

**Example**:
```bash
# Add to appropriate test suite in generate-tests.sh
test_bug_fix_issue_123() {
    print_test "Bug #123: Symlink targets with spaces handled correctly"

    # Create test case that would fail before fix
    mkdir -p "$TEST_DIR/path with spaces"
    echo "test" > "$TEST_DIR/path with spaces/file.txt"

    # Test the fix
    output=$("$SYMLINKIT" --list "$TEST_DIR" 2>&1)
    assert_contains "$output" "path with spaces"
}
```

### ✨ New Features
**Test Requirements**:
- ✅ Basic functionality tests (happy path)
- ✅ Edge case handling tests
- ✅ Error condition tests (invalid inputs)
- ✅ Integration tests with existing features
- ✅ Cross-platform compatibility tests (if applicable)

**Example**:
```bash
# For a new --sort-reverse flag
test_sort_reverse_flag() {
    print_test "Sort reverse flag functionality"
    output=$("$SYMLINKIT" --sort-reverse path --list "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" "good_link"

    print_test "Sort reverse with invalid sort type"
    output=$("$SYMLINKIT" --sort-reverse invalid 2>&1)
    # Should fail
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

### 🔧 Improvements & Refactoring
**Test Requirements**:
- ✅ All existing tests must continue to pass
- ✅ If behavior changes, update corresponding tests
- ✅ Add performance tests if relevant
- ✅ Add tests for new error conditions (if any)

### 📚 Documentation
**Test Requirements**:
- ✅ Verify examples in documentation actually work
- ✅ Add tests for any new usage patterns documented

---

## 🔄 Development Workflow

### Step 1: Issue Discussion
Before starting significant work:
1. Check existing [issues](https://github.com/ctrl-alt-adrian/symlinkit/issues)
2. Create an issue describing your proposed change
3. Discuss approach with maintainers
4. Get approval for major changes

### Step 2: Development
```bash
# Create feature branch
git checkout -b feature/descriptive-name

# Make your changes
# Edit symlinkit script
# Update documentation if needed

# CRITICAL: Add tests (see Testing Requirements section)
```

### Step 3: Testing (MANDATORY)
```bash
# Generate tests with your additions
./generate-tests.sh

# Run full test suite
./run_tests.sh

# Verify your specific tests
./simple_test.sh | grep -A5 -B5 "your test name"

# Test on different environments if possible
# (Linux, macOS, with/without optional dependencies)
```

### Step 4: Documentation Updates
Update relevant documentation:
- `README.md` (if adding new features or changing usage)
- `CHANGELOG.md` (add entry for your change)
- `man/symlinkit.1` (if adding flags or changing behavior)
- Version numbers (if releasing)

### Step 5: Commit & Push
```bash
# Stage all changes including test modifications
git add .

# Commit with descriptive message
git commit -m "feat: add --sort-reverse flag with comprehensive tests

- Implements reverse sorting for --sort flag
- Adds error handling for invalid sort types
- Includes integration tests with existing sort functionality
- Updates man page and help text

Tests added:
- Basic reverse sort functionality
- Error handling for invalid parameters
- Integration with existing --sort flag
- Cross-platform compatibility"

# Push to your fork
git push origin feature/descriptive-name
```

---

## 🧪 Testing Requirements (MANDATORY)

### Understanding the Test System

symlinkit uses a generated test system. Tests are created by modifying `generate-tests.sh`:

```bash
# View current test structure
./generate-tests.sh
head -50 simple_test.sh

# See [[Testing Framework]] wiki page for complete guide
```

### Adding Tests: Step-by-Step

#### 1. Identify the Right Test Suite
- **Basic functionality, flags, core features** → `simple_test.sh`
- **JSON output, formatting** → `test_json_fallback.sh`
- **Major new feature** → Create new test file

#### 2. Edit the Test Generator
```bash
# Open generate-tests.sh
vim generate-tests.sh

# Find the appropriate cat > filename << 'EOF' section
# Add your test function
```

#### 3. Test Function Template
```bash
test_your_feature() {
    echo -e "${BLUE}=== Testing Your Feature ===${RESET}"

    # Test 1: Basic functionality
    print_test "Feature works with valid input"
    output=$("$SYMLINKIT" --your-flag valid_input 2>&1)
    assert_contains "$output" "expected_output"

    # Test 2: Error handling
    print_test "Feature rejects invalid input"
    output=$("$SYMLINKIT" --your-flag invalid_input 2>&1)
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi

    # Test 3: Integration with other features
    print_test "Feature works with existing flags"
    output=$("$SYMLINKIT" --your-flag --json "$TEST_DIR/json_test" 2>&1)
    assert_contains "$output" '"path"'
}
```

#### 4. Add Function to Test Suite
Find the `main()` function in your chosen test file and add your test:
```bash
main() {
    # ... existing setup ...

    test_basic_commands
    test_json_functionality
    test_symlink_operations
    test_your_feature  # <-- Add this line

    print_summary
}
```

#### 5. Verify Your Tests
```bash
# Regenerate with your changes
./generate-tests.sh

# Run to see your tests
./simple_test.sh | grep -A10 "Testing Your Feature"

# Ensure tests fail appropriately
# (temporarily break your feature to verify test catches it)
```

### Test Quality Standards

#### ✅ Good Tests
```bash
test_good_example() {
    print_test "Clear, specific description"

    # Setup if needed
    mkdir -p "$TEST_DIR/specific_test"

    # Test specific behavior
    output=$("$SYMLINKIT" --specific-flag specific_input 2>&1)
    assert_contains "$output" "specific_expected_output"

    # Test error case
    print_test "Handles error case appropriately"
    output=$("$SYMLINKIT" --specific-flag invalid_input 2>&1)
    # Verify it fails as expected
    if [[ $? -ne 0 ]]; then
        echo -e "${GREEN}✓ PASS${RESET}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL${RESET}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}
```

#### ❌ Bad Tests
```bash
test_bad_example() {
    print_test "Vague description"

    # No setup or context

    # Test is too broad
    output=$("$SYMLINKIT" --some-flag 2>&1)
    assert_success  # Doesn't verify specific behavior

    # No error case testing
    # No cleanup
}
```

### Required Test Coverage

For any contribution, you MUST include:

#### ✅ Basic Functionality
```bash
# Test the happy path works
output=$("$SYMLINKIT" --your-flag normal_case 2>&1)
assert_contains "$output" "expected_result"
```

#### ✅ Error Handling
```bash
# Test invalid input is rejected
output=$("$SYMLINKIT" --your-flag invalid_input 2>&1)
[[ $? -ne 0 ]] && success || fail
```

#### ✅ Edge Cases
```bash
# Test boundary conditions, empty inputs, etc.
output=$("$SYMLINKIT" --your-flag "" 2>&1)
# Appropriate handling
```

#### ✅ Integration
```bash
# Test works with other flags
output=$("$SYMLINKIT" --your-flag --existing-flag input 2>&1)
assert_contains "$output" "combined_result"
```

#### ✅ Cross-Platform (if relevant)
```bash
case "$(uname -s)" in
    Linux*|Darwin*)
        # Run platform-specific tests
        ;;
    *)
        echo -e "${YELLOW}Skipping on unsupported OS${RESET}"
        ;;
esac
```

---

## 📏 Code Quality Standards

### Bash Style Guidelines
```bash
# ✅ Good: Use proper error handling
set -euo pipefail

# ✅ Good: Quote variables
if [[ -f "$file_path" ]]; then

# ✅ Good: Use meaningful variable names
local source_directory="$1"

# ✅ Good: Add comments for complex logic
# Convert "Select" to "Specify" for manual input
local manual_prompt="${prompt/Select/Specify}"

# ❌ Bad: Unquoted variables
if [[ -f $file_path ]]; then

# ❌ Bad: Cryptic variable names
local sd="$1"

# ❌ Bad: No error handling
# Commands that might fail without 'set -e'
```

### Function Documentation
```bash
# ✅ Good: Document complex functions
# Hybrid directory selection (fzf or manual)
select_directory() {
  local search_path="$1"
  local mindepth="${2:-0}"
  local maxdepth="${3:-5}"
  local prompt="${4:-Select a directory}"

  # Implementation...
}
```

### Consistency
- Follow existing patterns in the codebase
- Use the same color variables (`$RED`, `$GREEN`, etc.)
- Match existing function naming conventions
- Maintain consistent flag parsing style

---

## 📝 Pull Request Process

### Before Submitting

#### ✅ Pre-submission Checklist
- [ ] **Tests added and passing** (MANDATORY)
- [ ] All existing tests pass
- [ ] Documentation updated (README, man page, CHANGELOG)
- [ ] Code follows project style guidelines
- [ ] Feature branch is up-to-date with main
- [ ] Commit messages are clear and descriptive

### Submission Requirements

#### Pull Request Template
When creating your PR, include:

```markdown
## Description
Brief description of your changes and motivation.

## Changes Made
- List specific changes
- Include any new flags or features
- Note any breaking changes

## Testing
- [ ] Added tests for new functionality
- [ ] All existing tests pass
- [ ] Tested on multiple platforms (if relevant)
- [ ] Manual testing completed

### Test Details
Describe the tests you added:
- Test 1: What it tests and why
- Test 2: Error conditions covered
- Test 3: Integration scenarios

## Documentation Updates
- [ ] README.md updated
- [ ] CHANGELOG.md entry added
- [ ] Man page updated (if needed)
- [ ] Version numbers updated (if releasing)

## Verification
Run these commands to verify:
```bash
./generate-tests.sh
./run_tests.sh
./symlinkit --help  # Should show new flags
```

### Review Process

#### What Reviewers Check
1. **Tests exist and are comprehensive** (blocking requirement)
2. **All tests pass**
3. **Code quality and style**
4. **Documentation completeness**
5. **Backwards compatibility**
6. **Cross-platform compatibility**

#### Common Review Feedback
- "Please add tests for error conditions"
- "Tests should cover edge cases"
- "Need integration tests with existing features"
- "Documentation needs updating"
- "Please follow existing code style"

#### Addressing Feedback
```bash
# Make requested changes
# Add/update tests
./generate-tests.sh
./run_tests.sh

# Commit changes
git add .
git commit -m "address review feedback: add edge case tests"
git push origin feature/your-feature
```

---

## 🆘 Getting Help

### Resources
- **[[Testing Framework]]** - Comprehensive testing guide
- **[[Usage Examples]]** - See how features should work
- **[GitHub Issues](https://github.com/ctrl-alt-adrian/symlinkit/issues)** - Report bugs or ask questions
- **[GitHub Discussions](https://github.com/ctrl-alt-adrian/symlinkit/discussions)** - General questions

### Common Questions

#### Q: "I'm not sure what tests to add"
A: Look at existing tests as examples. Every feature should have:
- Basic functionality test
- Error handling test
- Integration test (if it works with other flags)

#### Q: "My tests are failing"
A: Debug approach:
```bash
# Run specific test file
./simple_test.sh

# Check what your feature actually outputs
./symlinkit --your-flag test_input

# Compare with what test expects
grep -A5 "your test" simple_test.sh
```

#### Q: "Tests pass locally but fail in PR"
A: Usually indicates:
- Platform differences (test on Linux if you're on macOS)
- Missing test cleanup
- Dependency assumptions

#### Q: "How do I test interactive features?"
A: Focus on non-interactive aspects:
```bash
# ✅ Good: Test flag behavior
./symlinkit --no-fzf --list directory

# ❌ Avoid: Testing actual interactive prompts
# (These are hard to automate reliably)
```

### Getting Help from Maintainers
1. **Search existing issues** first
2. **Provide specific details**:
   - What you're trying to implement
   - What tests you've tried
   - Error messages or unexpected behavior
3. **Include test code** in help requests

---

## 🏆 Recognition

Contributors who follow these guidelines and provide comprehensive tests will be:
- ✨ Acknowledged in CHANGELOG.md
- 🎯 Fast-tracked for review
- 🤝 Invited to review future PRs
- 📈 Considered for maintainer status (for regular contributors)

---

## ⚠️ Final Reminder

**ALL CONTRIBUTIONS MUST INCLUDE TESTS. NO EXCEPTIONS.**

This policy exists to:
- Ensure symlinkit remains reliable
- Prevent regressions
- Make future changes safer
- Maintain code quality
- Help new contributors understand expected behavior

If you're unsure about testing requirements, ask for help early rather than submitting without tests.

**Thank you for contributing to symlinkit! 🚀**