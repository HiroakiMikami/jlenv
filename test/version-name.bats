#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${JLENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
}

@test "no version selected" {
  assert [ ! -d "${JLENV_ROOT}/versions" ]
  run jlenv-version-name
  assert_success "system"
}

@test "system version is not checked for existance" {
  JLENV_VERSION=system run jlenv-version-name
  assert_success "system"
}

@test "JLENV_VERSION can be overridden by hook" {
  create_version "1.8.7"
  create_version "1.9.3"
  create_hook version-name test.bash <<<"JLENV_VERSION=1.9.3"

  JLENV_VERSION=1.8.7 run jlenv-version-name
  assert_success "1.9.3"
}

@test "carries original IFS within hooks" {
  create_hook version-name hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
SH

  export JLENV_VERSION=system
  IFS=$' \t\n' run jlenv-version-name env
  assert_success
  assert_line "HELLO=:hello:ugly:world:again"
}

@test "JLENV_VERSION has precedence over local" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > ".julia-version" <<<"1.8.7"
  run jlenv-version-name
  assert_success "1.8.7"

  JLENV_VERSION=1.9.3 run jlenv-version-name
  assert_success "1.9.3"
}

@test "local file has precedence over global" {
  create_version "1.8.7"
  create_version "1.9.3"

  cat > "${JLENV_ROOT}/version" <<<"1.8.7"
  run jlenv-version-name
  assert_success "1.8.7"

  cat > ".julia-version" <<<"1.9.3"
  run jlenv-version-name
  assert_success "1.9.3"
}

@test "missing version" {
  JLENV_VERSION=1.2 run jlenv-version-name
  assert_failure "jlenv: version \`1.2' is not installed (set by JLENV_VERSION environment variable)"
}

@test "version with prefix in name" {
  create_version "1.8.7"
  cat > ".julia-version" <<<"julia-1.8.7"
  run jlenv-version-name
  assert_success
  assert_output "1.8.7"
}
