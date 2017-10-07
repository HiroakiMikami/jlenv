#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
}

@test "invocation without 2 arguments prints usage" {
  run jlenv-version-file-write
  assert_failure "Usage: jlenv version-file-write <file> <version>"
  run jlenv-version-file-write "one" ""
  assert_failure
}

@test "setting nonexistent version fails" {
  assert [ ! -e ".julia-version" ]
  run jlenv-version-file-write ".julia-version" "1.8.7"
  assert_failure "jlenv: version \`1.8.7' not installed"
  assert [ ! -e ".julia-version" ]
}

@test "writes value to arbitrary file" {
  mkdir -p "${JLENV_ROOT}/versions/1.8.7"
  assert [ ! -e "my-version" ]
  run jlenv-version-file-write "${PWD}/my-version" "1.8.7"
  assert_success ""
  assert [ "$(cat my-version)" = "1.8.7" ]
}
