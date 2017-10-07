#!/usr/bin/env bats

load test_helper

setup() {
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
}

create_file() {
  mkdir -p "$(dirname "$1")"
  touch "$1"
}

@test "detects global 'version' file" {
  create_file "${JLENV_ROOT}/version"
  run jlenv-version-file
  assert_success "${JLENV_ROOT}/version"
}

@test "prints global file if no version files exist" {
  assert [ ! -e "${JLENV_ROOT}/version" ]
  assert [ ! -e ".ruby-version" ]
  run jlenv-version-file
  assert_success "${JLENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".ruby-version"
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/.ruby-version"
}

@test "in parent directory" {
  create_file ".ruby-version"
  mkdir -p project
  cd project
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/.ruby-version"
}

@test "topmost file has precedence" {
  create_file ".ruby-version"
  create_file "project/.ruby-version"
  cd project
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/project/.ruby-version"
}

@test "JLENV_DIR has precedence over PWD" {
  create_file "widget/.ruby-version"
  create_file "project/.ruby-version"
  cd project
  JLENV_DIR="${JLENV_TEST_DIR}/widget" run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/widget/.ruby-version"
}

@test "PWD is searched if JLENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.ruby-version"
  cd project
  JLENV_DIR="${JLENV_TEST_DIR}/widget/blank" run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/project/.ruby-version"
}

@test "finds version file in target directory" {
  create_file "project/.ruby-version"
  run jlenv-version-file "${PWD}/project"
  assert_success "${JLENV_TEST_DIR}/project/.ruby-version"
}

@test "fails when no version file in target directory" {
  run jlenv-version-file "$PWD"
  assert_failure ""
}
