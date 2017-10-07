#!/usr/bin/env bats

load test_helper

create_version() {
  mkdir -p "${JLENV_ROOT}/versions/$1"
}

setup() {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
}

stub_system_ruby() {
  local stub="${JLENV_TEST_DIR}/bin/ruby"
  mkdir -p "$(dirname "$stub")"
  touch "$stub" && chmod +x "$stub"
}

@test "no versions installed" {
  stub_system_ruby
  assert [ ! -d "${JLENV_ROOT}/versions" ]
  run jlenv-versions
  assert_success "* system (set by ${JLENV_ROOT}/version)"
}

@test "not even system ruby available" {
  PATH="$(path_without ruby)" run jlenv-versions
  assert_failure
  assert_output "Warning: no Ruby detected on the system"
}

@test "bare output no versions installed" {
  assert [ ! -d "${JLENV_ROOT}/versions" ]
  run jlenv-versions --bare
  assert_success ""
}

@test "single version installed" {
  stub_system_ruby
  create_version "1.9"
  run jlenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${JLENV_ROOT}/version)
  1.9
OUT
}

@test "single version bare" {
  create_version "1.9"
  run jlenv-versions --bare
  assert_success "1.9"
}

@test "multiple versions" {
  stub_system_ruby
  create_version "1.8.7"
  create_version "1.9.3"
  create_version "2.0.0"
  run jlenv-versions
  assert_success
  assert_output <<OUT
* system (set by ${JLENV_ROOT}/version)
  1.8.7
  1.9.3
  2.0.0
OUT
}

@test "indicates current version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  JLENV_VERSION=1.9.3 run jlenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by JLENV_VERSION environment variable)
  2.0.0
OUT
}

@test "bare doesn't indicate current version" {
  create_version "1.9.3"
  create_version "2.0.0"
  JLENV_VERSION=1.9.3 run jlenv-versions --bare
  assert_success
  assert_output <<OUT
1.9.3
2.0.0
OUT
}

@test "globally selected version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  cat > "${JLENV_ROOT}/version" <<<"1.9.3"
  run jlenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${JLENV_ROOT}/version)
  2.0.0
OUT
}

@test "per-project version" {
  stub_system_ruby
  create_version "1.9.3"
  create_version "2.0.0"
  cat > ".ruby-version" <<<"1.9.3"
  run jlenv-versions
  assert_success
  assert_output <<OUT
  system
* 1.9.3 (set by ${JLENV_TEST_DIR}/.ruby-version)
  2.0.0
OUT
}

@test "ignores non-directories under versions" {
  create_version "1.9"
  touch "${JLENV_ROOT}/versions/hello"

  run jlenv-versions --bare
  assert_success "1.9"
}

@test "lists symlinks under versions" {
  create_version "1.8.7"
  ln -s "1.8.7" "${JLENV_ROOT}/versions/1.8"

  run jlenv-versions --bare
  assert_success
  assert_output <<OUT
1.8
1.8.7
OUT
}

@test "doesn't list symlink aliases when --skip-aliases" {
  create_version "1.8.7"
  ln -s "1.8.7" "${JLENV_ROOT}/versions/1.8"
  mkdir moo
  ln -s "${PWD}/moo" "${JLENV_ROOT}/versions/1.9"

  run jlenv-versions --bare --skip-aliases
  assert_success

  assert_output <<OUT
1.8.7
1.9
OUT
}
