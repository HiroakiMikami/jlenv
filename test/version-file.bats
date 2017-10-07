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
  assert [ ! -e ".julia-version" ]
  run jlenv-version-file
  assert_success "${JLENV_ROOT}/version"
}

@test "in current directory" {
  create_file ".julia-version"
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/.julia-version"
}

@test "in parent directory" {
  create_file ".julia-version"
  mkdir -p project
  cd project
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/.julia-version"
}

@test "topmost file has precedence" {
  create_file ".julia-version"
  create_file "project/.julia-version"
  cd project
  run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/project/.julia-version"
}

@test "JLENV_DIR has precedence over PWD" {
  create_file "widget/.julia-version"
  create_file "project/.julia-version"
  cd project
  JLENV_DIR="${JLENV_TEST_DIR}/widget" run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/widget/.julia-version"
}

@test "PWD is searched if JLENV_DIR yields no results" {
  mkdir -p "widget/blank"
  create_file "project/.julia-version"
  cd project
  JLENV_DIR="${JLENV_TEST_DIR}/widget/blank" run jlenv-version-file
  assert_success "${JLENV_TEST_DIR}/project/.julia-version"
}

@test "finds version file in target directory" {
  create_file "project/.julia-version"
  run jlenv-version-file "${PWD}/project"
  assert_success "${JLENV_TEST_DIR}/project/.julia-version"
}

@test "fails when no version file in target directory" {
  run jlenv-version-file "$PWD"
  assert_failure ""
}
