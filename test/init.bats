#!/usr/bin/env bats

load test_helper

@test "creates shims and versions directories" {
  assert [ ! -d "${JLENV_ROOT}/shims" ]
  assert [ ! -d "${JLENV_ROOT}/versions" ]
  run jlenv-init -
  assert_success
  assert [ -d "${JLENV_ROOT}/shims" ]
  assert [ -d "${JLENV_ROOT}/versions" ]
}

@test "auto rehash" {
  run jlenv-init -
  assert_success
  assert_line "command jlenv rehash 2>/dev/null"
}

@test "setup shell completions" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run jlenv-init - bash
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/jlenv.bash'"
}

@test "detect parent shell" {
  SHELL=/bin/false run jlenv-init -
  assert_success
  assert_line "export JLENV_SHELL=bash"
}

@test "detect parent shell from script" {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
  cat > myscript.sh <<OUT
#!/bin/sh
eval "\$(jlenv-init -)"
echo \$JLENV_SHELL
OUT
  chmod +x myscript.sh
  run ./myscript.sh /bin/zsh
  assert_success "sh"
}

@test "setup shell completions (fish)" {
  root="$(cd $BATS_TEST_DIRNAME/.. && pwd)"
  run jlenv-init - fish
  assert_success
  assert_line "source '${root}/test/../libexec/../completions/jlenv.fish'"
}

@test "fish instructions" {
  run jlenv-init fish
  assert [ "$status" -eq 1 ]
  assert_line 'status --is-interactive; and source (jlenv init -|psub)'
}

@test "option to skip rehash" {
  run jlenv-init - --no-rehash
  assert_success
  refute_line "jlenv rehash 2>/dev/null"
}

@test "adds shims to PATH" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run jlenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${JLENV_ROOT}'/shims:${PATH}"'
}

@test "adds shims to PATH (fish)" {
  export PATH="${BATS_TEST_DIRNAME}/../libexec:/usr/bin:/bin:/usr/local/bin"
  run jlenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${JLENV_ROOT}/shims' \$PATH"
}

@test "can add shims to PATH more than once" {
  export PATH="${JLENV_ROOT}/shims:$PATH"
  run jlenv-init - bash
  assert_success
  assert_line 0 'export PATH="'${JLENV_ROOT}'/shims:${PATH}"'
}

@test "can add shims to PATH more than once (fish)" {
  export PATH="${JLENV_ROOT}/shims:$PATH"
  run jlenv-init - fish
  assert_success
  assert_line 0 "set -gx PATH '${JLENV_ROOT}/shims' \$PATH"
}

@test "outputs sh-compatible syntax" {
  run jlenv-init - bash
  assert_success
  assert_line '  case "$command" in'

  run jlenv-init - zsh
  assert_success
  assert_line '  case "$command" in'
}

@test "outputs fish-specific syntax (fish)" {
  run jlenv-init - fish
  assert_success
  assert_line '  switch "$command"'
  refute_line '  case "$command" in'
}
