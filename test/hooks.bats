#!/usr/bin/env bats

load test_helper

@test "prints usage help given no argument" {
  run jlenv-hooks
  assert_failure "Usage: jlenv hooks <command>"
}

@test "prints list of hooks" {
  path1="${JLENV_TEST_DIR}/jlenv.d"
  path2="${JLENV_TEST_DIR}/etc/jlenv_hooks"
  JLENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  create_hook exec "ahoy.bash"
  create_hook exec "invalid.sh"
  create_hook which "boom.bash"
  JLENV_HOOK_PATH="$path2"
  create_hook exec "bueno.bash"

  JLENV_HOOK_PATH="$path1:$path2" run jlenv-hooks exec
  assert_success
  assert_output <<OUT
${JLENV_TEST_DIR}/jlenv.d/exec/ahoy.bash
${JLENV_TEST_DIR}/jlenv.d/exec/hello.bash
${JLENV_TEST_DIR}/etc/jlenv_hooks/exec/bueno.bash
OUT
}

@test "supports hook paths with spaces" {
  path1="${JLENV_TEST_DIR}/my hooks/jlenv.d"
  path2="${JLENV_TEST_DIR}/etc/jlenv hooks"
  JLENV_HOOK_PATH="$path1"
  create_hook exec "hello.bash"
  JLENV_HOOK_PATH="$path2"
  create_hook exec "ahoy.bash"

  JLENV_HOOK_PATH="$path1:$path2" run jlenv-hooks exec
  assert_success
  assert_output <<OUT
${JLENV_TEST_DIR}/my hooks/jlenv.d/exec/hello.bash
${JLENV_TEST_DIR}/etc/jlenv hooks/exec/ahoy.bash
OUT
}

@test "resolves relative paths" {
  JLENV_HOOK_PATH="${JLENV_TEST_DIR}/jlenv.d"
  create_hook exec "hello.bash"
  mkdir -p "$HOME"

  JLENV_HOOK_PATH="${HOME}/../jlenv.d" run jlenv-hooks exec
  assert_success "${JLENV_TEST_DIR}/jlenv.d/exec/hello.bash"
}

@test "resolves symlinks" {
  path="${JLENV_TEST_DIR}/jlenv.d"
  mkdir -p "${path}/exec"
  mkdir -p "$HOME"
  touch "${HOME}/hola.bash"
  ln -s "../../home/hola.bash" "${path}/exec/hello.bash"
  touch "${path}/exec/bright.sh"
  ln -s "bright.sh" "${path}/exec/world.bash"

  JLENV_HOOK_PATH="$path" run jlenv-hooks exec
  assert_success
  assert_output <<OUT
${HOME}/hola.bash
${JLENV_TEST_DIR}/jlenv.d/exec/bright.sh
OUT
}
