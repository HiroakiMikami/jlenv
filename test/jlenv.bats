#!/usr/bin/env bats

load test_helper

@test "blank invocation" {
  run jlenv
  assert_failure
  assert_line 0 "$(jlenv---version)"
}

@test "invalid command" {
  run jlenv does-not-exist
  assert_failure
  assert_output "jlenv: no such command \`does-not-exist'"
}

@test "default JLENV_ROOT" {
  JLENV_ROOT="" HOME=/home/mislav run jlenv root
  assert_success
  assert_output "/home/mislav/.jlenv"
}

@test "inherited JLENV_ROOT" {
  JLENV_ROOT=/opt/jlenv run jlenv root
  assert_success
  assert_output "/opt/jlenv"
}

@test "default JLENV_DIR" {
  run jlenv echo JLENV_DIR
  assert_output "$(pwd)"
}

@test "inherited JLENV_DIR" {
  dir="${BATS_TMPDIR}/myproject"
  mkdir -p "$dir"
  JLENV_DIR="$dir" run jlenv echo JLENV_DIR
  assert_output "$dir"
}

@test "invalid JLENV_DIR" {
  dir="${BATS_TMPDIR}/does-not-exist"
  assert [ ! -d "$dir" ]
  JLENV_DIR="$dir" run jlenv echo JLENV_DIR
  assert_failure
  assert_output "jlenv: cannot change working directory to \`$dir'"
}

@test "adds its own libexec to PATH" {
  run jlenv echo "PATH"
  assert_success "${BATS_TEST_DIRNAME%/*}/libexec:$PATH"
}

@test "adds plugin bin dirs to PATH" {
  mkdir -p "$JLENV_ROOT"/plugins/ruby-build/bin
  mkdir -p "$JLENV_ROOT"/plugins/jlenv-each/bin
  run jlenv echo -F: "PATH"
  assert_success
  assert_line 0 "${BATS_TEST_DIRNAME%/*}/libexec"
  assert_line 1 "${JLENV_ROOT}/plugins/ruby-build/bin"
  assert_line 2 "${JLENV_ROOT}/plugins/jlenv-each/bin"
}

@test "JLENV_HOOK_PATH preserves value from environment" {
  JLENV_HOOK_PATH=/my/hook/path:/other/hooks run jlenv echo -F: "JLENV_HOOK_PATH"
  assert_success
  assert_line 0 "/my/hook/path"
  assert_line 1 "/other/hooks"
  assert_line 2 "${JLENV_ROOT}/jlenv.d"
}

@test "JLENV_HOOK_PATH includes jlenv built-in plugins" {
  unset JLENV_HOOK_PATH
  run jlenv echo "JLENV_HOOK_PATH"
  assert_success "${JLENV_ROOT}/jlenv.d:${BATS_TEST_DIRNAME%/*}/jlenv.d:/usr/local/etc/jlenv.d:/etc/jlenv.d:/usr/lib/jlenv/hooks"
}
