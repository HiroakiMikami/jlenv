#!/usr/bin/env bats

load test_helper

@test "no shims" {
  run jlenv-shims
  assert_success
  assert [ -z "$output" ]
}

@test "shims" {
  mkdir -p "${JLENV_ROOT}/shims"
  touch "${JLENV_ROOT}/shims/ruby"
  touch "${JLENV_ROOT}/shims/irb"
  run jlenv-shims
  assert_success
  assert_line "${JLENV_ROOT}/shims/ruby"
  assert_line "${JLENV_ROOT}/shims/irb"
}

@test "shims --short" {
  mkdir -p "${JLENV_ROOT}/shims"
  touch "${JLENV_ROOT}/shims/ruby"
  touch "${JLENV_ROOT}/shims/irb"
  run jlenv-shims --short
  assert_success
  assert_line "irb"
  assert_line "ruby"
}
