#!/usr/bin/env bats

load ./helpers.bash

# --- Basic Commands ---

@test "Version flag" {
  run run_symlinkit --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ symlinkit ]]
}

@test "Help flag" {
  run run_symlinkit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ Usage ]]
}

@test "Invalid flag combination -cd" {
  run run_symlinkit -cd
  [ "$status" -ne 0 ]
  [[ "$output" =~ Invalid ]]
}

@test "Invalid flag combination -md" {
  run run_symlinkit -md
  [ "$status" -ne 0 ]
  [[ "$output" =~ Invalid ]]
}

@test "Invalid flag combination -co" {
  run run_symlinkit -co
  [ "$status" -ne 0 ]
  [[ "$output" =~ Invalid ]]
}

# --- Symlink Operations ---

@test "Create mode dry-run" {
  run run_symlinkit --dry-run -c "$TMPDIR/source/file.txt" "$TMPDIR/dest/new_link"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
  [ ! -e "$TMPDIR/dest/new_link" ]
}

@test "Create mode actual" {
  run run_symlinkit -c "$TMPDIR/source/file.txt" "$TMPDIR/dest/actual_link"
  [ "$status" -eq 0 ]
  [ -L "$TMPDIR/dest/actual_link" ]
}

@test "Create mode fails if exists" {
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/existing"
  run run_symlinkit -c "$TMPDIR/source/file.txt" "$TMPDIR/dest/existing"
  [ "$status" -ne 0 ]
  [[ "$output" =~ exists ]]
}

@test "Require operation flag with source path" {
  run run_symlinkit "$TMPDIR/source"
  [ "$status" -ne 0 ]
  [[ "$output" =~ No\ operation ]]
}

@test "Overwrite mode dry-run" {
  run run_symlinkit --dry-run -o "$TMPDIR/source/file.txt" "$TMPDIR/dest/test_link"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
}

@test "Overwrite mode actual" {
  mkdir -p "$TMPDIR/dest/temp_target"
  echo "temp" > "$TMPDIR/dest/temp_target/oldfile"
  run run_symlinkit -o "$TMPDIR/source/file.txt" "$TMPDIR/dest/temp_target"
  [ "$status" -eq 0 ]
  [ -L "$TMPDIR/dest/temp_target/file.txt" ]
}

@test "Merge mode dry-run" {
  run run_symlinkit --dry-run -m "$TMPDIR/source" "$TMPDIR/dest/merge_test"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
}

@test "Merge mode actual" {
  run bash -c "echo s | $BATS_TEST_DIRNAME/../symlinkit -m \"$TMPDIR/source\" \"$TMPDIR/dest/merge_actual\""
  [ "$status" -eq 0 ]
  [ -d "$TMPDIR/dest/merge_actual" ]
}

@test "Delete mode dry-run" {
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/delete_test"
  run run_symlinkit --dry-run -d "$TMPDIR/dest/delete_test"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
  [ -L "$TMPDIR/dest/delete_test" ]
}

@test "Delete mode actual" {
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/delete_test2"
  run run_symlinkit -d "$TMPDIR/dest/delete_test2"
  [ "$status" -eq 0 ]
  [ ! -L "$TMPDIR/dest/delete_test2" ]
}

@test "Delete preserves source file" {
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/preserve_test"
  run run_symlinkit -d "$TMPDIR/dest/preserve_test"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR/source/file.txt" ]
}

@test "Recursive delete dry-run" {
  mkdir -p "$TMPDIR/dest/rec_delete"
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/rec_delete/link1"
  run bash -c "echo d | $BATS_TEST_DIRNAME/../symlinkit --dry-run -dr \"$TMPDIR/dest/rec_delete\""
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
  [ -L "$TMPDIR/dest/rec_delete/link1" ]
}

@test "Recursive delete dry-run with all" {
  mkdir -p "$TMPDIR/dest/rec_delete"
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/rec_delete/link1"
  run bash -c "echo a | $BATS_TEST_DIRNAME/../symlinkit --dry-run -dr \"$TMPDIR/dest/rec_delete\""
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
  [ -L "$TMPDIR/dest/rec_delete/link1" ]
}

@test "Recursive delete skip all" {
  mkdir -p "$TMPDIR/dest/rec_delete"
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/rec_delete/link1"
  run bash -c "echo s | $BATS_TEST_DIRNAME/../symlinkit -dr \"$TMPDIR/dest/rec_delete\""
  [ "$status" -eq 0 ]
  [ -L "$TMPDIR/dest/rec_delete/link1" ]
}

@test "Recursive delete actual (delete all)" {
  rm -rf "$TMPDIR/dest/rec_delete"
  mkdir -p "$TMPDIR/dest/rec_delete"
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/rec_delete/link1"
  ln -s "$TMPDIR/source/file.txt" "$TMPDIR/dest/rec_delete/link2"
  run bash -c "echo a | $BATS_TEST_DIRNAME/../symlinkit -dr \"$TMPDIR/dest/rec_delete\""
  [ "$status" -eq 0 ]
  [ ! -L "$TMPDIR/dest/rec_delete/link1" ]
  [ ! -L "$TMPDIR/dest/rec_delete/link2" ]
  [ -f "$TMPDIR/source/file.txt" ]
}

@test "Flag chaining: -cr (create recursive)" {
  run bash -c "echo s | $BATS_TEST_DIRNAME/../symlinkit -cr \"$TMPDIR/source\" \"$TMPDIR/dest/cr_test\""
  [ "$status" -eq 0 ]
  [ -d "$TMPDIR/dest/cr_test" ]
}

@test "Flag chaining: -or (overwrite recursive)" {
  mkdir -p "$TMPDIR/dest/or_test"
  run bash -c "echo s | $BATS_TEST_DIRNAME/../symlinkit -or \"$TMPDIR/source\" \"$TMPDIR/dest/or_test\""
  [ "$status" -eq 0 ]
  [ -d "$TMPDIR/dest/or_test" ]
}

@test "List mode" {
  run run_symlinkit --list "$TMPDIR/json_test"
  [ "$status" -eq 0 ]
  [[ "$output" =~ good_link ]]
}

@test "Broken mode" {
  run run_symlinkit --broken "$TMPDIR/json_test"
  [ "$status" -eq 0 ]
  [[ "$output" =~ broken_link ]]
}

@test "Fix-broken with delete all" {
  mkdir -p "$TMPDIR/fix_test"
  ln -s "/nonexistent1" "$TMPDIR/fix_test/b1"
  ln -s "/nonexistent2" "$TMPDIR/fix_test/b2"
  run bash -c "echo a | $BATS_TEST_DIRNAME/../symlinkit --fix-broken \"$TMPDIR/fix_test\""
  [ "$status" -eq 0 ]
  [ ! -L "$TMPDIR/fix_test/b1" ]
}

@test "Fix-broken dry-run with delete all" {
  mkdir -p "$TMPDIR/fix_test"
  ln -s "/nonexistent3" "$TMPDIR/fix_test/b3"
  run bash -c "echo a | $BATS_TEST_DIRNAME/../symlinkit --dry-run --fix-broken \"$TMPDIR/fix_test\""
  [ "$status" -eq 0 ]
  [[ "$output" =~ Would ]]
  [ -L "$TMPDIR/fix_test/b3" ]
}

@test "List mode with no symlinks" {
  mkdir -p "$TMPDIR/empty_dir"
  run run_symlinkit --list "$TMPDIR/empty_dir"
  [ "$status" -eq 0 ]
  [[ "$output" =~ No\ symlinks ]]
}

