setup() {
  TMPDIR=$(mktemp -d)
  mkdir -p "$TMPDIR"/{source,dest,json_test}
  echo "test file" > "$TMPDIR/source/file.txt"
  ln -sf "$TMPDIR/source/file.txt" "$TMPDIR/json_test/good_link"
  ln -sf "/nonexistent/path" "$TMPDIR/json_test/broken_link"
}

teardown() {
  rm -rf "$TMPDIR"
}

run_symlinkit() {
  "$BATS_TEST_DIRNAME/../symlinkit" "$@"
}

