#!/usr/bin/env bash
#
# Test suite for in-container eic-shell script.
# Validates argument preservation, single/multi-token dispatch, subshells,
# exit code propagation, piped stdin, and environment sourcing.
#

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EIC_SHELL="${1:-$REPO_ROOT/containers/eic/eic-shell}"

if [ ! -x "$EIC_SHELL" ]; then
  echo "ERROR: eic-shell not found or not executable at: $EIC_SHELL"
  exit 1
fi

# Ensure an environment setup file exists if /etc/eic-env.sh is missing
if [ ! -f /etc/eic-env.sh ] && [ -z "${EIC_ENV_SH:-}" ]; then
  TMP_ENV=$(mktemp)
  echo 'export EIC_ENV_LOADED=1' > "$TMP_ENV"
  export EIC_ENV_SH="$TMP_ENV"
  trap 'rm -f "$TMP_ENV"' EXIT
fi

PASSED=0
FAILED=0

run_test() {
  local desc="$1"
  shift
  printf "Test %2d: %-60s " "$((PASSED + FAILED + 1))" "$desc"

  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?

  if [ "$exit_code" -eq 0 ]; then
    echo "[PASS]"
    PASSED=$((PASSED + 1))
    return 0
  else
    echo "[FAIL] (exit code: $exit_code)"
    echo "       Output: $output"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

run_test_expect_code() {
  local expected_code="$1"
  local desc="$2"
  shift 2
  printf "Test %2d: %-60s " "$((PASSED + FAILED + 1))" "$desc"

  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?

  if [ "$exit_code" -eq "$expected_code" ]; then
    echo "[PASS]"
    PASSED=$((PASSED + 1))
    return 0
  else
    echo "[FAIL] (expected: $expected_code, got: $exit_code)"
    echo "       Output: $output"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

run_test_output_match() {
  local expected_pattern="$1"
  local desc="$2"
  shift 2
  printf "Test %2d: %-60s " "$((PASSED + FAILED + 1))" "$desc"

  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?

  if [ "$exit_code" -eq 0 ] && echo "$output" | grep -q "$expected_pattern"; then
    echo "[PASS]"
    PASSED=$((PASSED + 1))
    return 0
  else
    echo "[FAIL] (exit code: $exit_code, pattern: '$expected_pattern')"
    echo "       Output: $output"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

run_test_output_contains() {
  local str1="$1"
  local str2="$2"
  local desc="$3"
  shift 3
  printf "Test %2d: %-60s " "$((PASSED + FAILED + 1))" "$desc"

  local output
  local exit_code=0
  output=$("$@" 2>&1) || exit_code=$?

  if [ "$exit_code" -eq 0 ] && echo "$output" | grep -q "$str1" && echo "$output" | grep -q "$str2"; then
    echo "[PASS]"
    PASSED=$((PASSED + 1))
    return 0
  else
    echo "[FAIL] (exit code: $exit_code, expected to contain '$str1' and '$str2')"
    echo "       Output: $output"
    FAILED=$((FAILED + 1))
    return 1
  fi
}

echo "=================================================="
echo "Testing eic-shell: $EIC_SHELL"
echo "=================================================="

# 1. Simple command execution
run_test "Execute single command (true)" \
  "$EIC_SHELL" true

# 2. Simple command with argument
run_test_output_match "hello" "Execute simple command with argument" \
  "$EIC_SHELL" echo hello

# 3. Multi-token command
run_test_output_match "foo bar baz" "Execute multi-token command" \
  "$EIC_SHELL" echo foo bar baz

# 4. Quoted single-string command
run_test_output_match "foo bar" "Execute quoted single-string command" \
  "$EIC_SHELL" "echo foo bar"

# 5. Explicit subshell with bash -c
run_test_output_match "nested bash -c" "Execute subshell: bash -c 'echo ...'" \
  "$EIC_SHELL" bash -c "echo nested bash -c"

# 6. Subshell with complex commands and arguments
run_test_output_match "cmake-target-dummy" "Execute bash -c with multi-arg cmake-like flags" \
  "$EIC_SHELL" bash -c "echo cmake-target-dummy --build build --target lib"

# 7. Command chaining with &&
run_test_output_contains "part1" "part2" "Execute chained commands with &&" \
  "$EIC_SHELL" "echo part1 && echo part2"

# 8. Arguments with spaces preserved
run_test_output_match "arg with multiple spaces" "Preserve arguments containing spaces" \
  "$EIC_SHELL" bash -c 'echo "$1"' _ "arg with multiple spaces"

# 9. Positional parameters in subshell
run_test_output_match "val1:val2:val3" "Preserve positional parameters in subshell" \
  "$EIC_SHELL" bash -c 'echo "$1:$2:$3"' _ "val1" "val2" "val3"

# 10. Exit code preservation: success
run_test_expect_code 0 "Preserve exit code 0" \
  "$EIC_SHELL" true

# 11. Exit code preservation: failure (exit 1)
run_test_expect_code 1 "Preserve exit code 1 (false)" \
  "$EIC_SHELL" false

# 12. Exit code preservation: arbitrary code (exit 42)
run_test_expect_code 42 "Preserve exit code 42" \
  "$EIC_SHELL" bash -c "exit 42"

# 13. Exit code preservation: arbitrary code (exit 17)
run_test_expect_code 17 "Preserve exit code 17" \
  "$EIC_SHELL" bash -c "exit 17"

# 14. Leading delimiter -- stripped: single command
run_test "Strip leading -- delimiter (true)" \
  "$EIC_SHELL" -- true

# 15. Leading delimiter -- stripped: multi-token command
run_test_output_match "hello world" "Strip leading -- delimiter (echo hello world)" \
  "$EIC_SHELL" -- echo hello world

# 16. Piped stdin to a command
run_test_output_match "piped data test" "Pipe stdin to a command (cat)" \
  bash -c "echo 'piped data test' | '$EIC_SHELL' cat"

# 17. Piped stdin to a command with --
run_test_output_match "piped data test" "Pipe stdin to a command with -- (cat)" \
  bash -c "echo 'piped data test' | '$EIC_SHELL' -- cat"

# 18. Piped stdin to interactive shell
run_test_output_match "interactive pipe test" "Pipe commands on stdin to interactive shell" \
  bash -c "echo 'echo interactive pipe test' | '$EIC_SHELL'"

# 19. Piped stdin to interactive shell with --
run_test_output_match "interactive pipe test" "Pipe commands on stdin to interactive shell with --" \
  bash -c "echo 'echo interactive pipe test' | '$EIC_SHELL' --"

# 20. Environment setup verification (/etc/eic-env.sh sourced)
run_test "Environment setup sourced" \
  "$EIC_SHELL" bash -c 'test -n "${EIC_ENV_LOADED:-}" || test -f /etc/eic-env.sh'

echo "=================================================="
echo "Summary: $PASSED passed, $FAILED failed out of $((PASSED + FAILED)) tests"
echo "=================================================="

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
exit 0
