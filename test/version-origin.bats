#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
}

@test "reports global file even if it doesn't exist" {
  assert [ ! -e "${JLENV_ROOT}/version" ]
  run jlenv-version-origin
  assert_success "${JLENV_ROOT}/version"
}

@test "detects global file" {
  mkdir -p "$JLENV_ROOT"
  touch "${JLENV_ROOT}/version"
  run jlenv-version-origin
  assert_success "${JLENV_ROOT}/version"
}

@test "detects JLENV_VERSION" {
  JLENV_VERSION=1 run jlenv-version-origin
  assert_success "JLENV_VERSION environment variable"
}

@test "detects local file" {
  touch .julia-version
  run jlenv-version-origin
  assert_success "${PWD}/.julia-version"
}

@test "reports from hook" {
  create_hook version-origin test.bash <<<"JLENV_VERSION_ORIGIN=plugin"

  JLENV_VERSION=1 run jlenv-version-origin
  assert_success "plugin"
}

@test "carries original IFS within hooks" {
  create_hook version-origin hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export JLENV_VERSION=system
  IFS=$' \t\n' run jlenv-version-origin env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "doesn't inherit JLENV_VERSION_ORIGIN from environment" {
  JLENV_VERSION_ORIGIN=ignored run jlenv-version-origin
  assert_success "${JLENV_ROOT}/version"
}
