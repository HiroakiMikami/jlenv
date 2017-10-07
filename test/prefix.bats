#!/usr/bin/env bats

load test_helper

@test "prefix" {
  mkdir -p "${JLENV_TEST_DIR}/myproject"
  cd "${JLENV_TEST_DIR}/myproject"
  echo "1.2.3" > .julia-version
  mkdir -p "${JLENV_ROOT}/versions/1.2.3"
  run jlenv-prefix
  assert_success "${JLENV_ROOT}/versions/1.2.3"
}

@test "prefix for invalid version" {
  JLENV_VERSION="1.2.3" run jlenv-prefix
  assert_failure "jlenv: version \`1.2.3' not installed"
}

@test "prefix for system" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  touch "${JLENV_TEST_DIR}/bin/julia"
  chmod +x "${JLENV_TEST_DIR}/bin/julia"
  JLENV_VERSION="system" run jlenv-prefix
  assert_success "$JLENV_TEST_DIR"
}

@test "prefix for system in /" {
  mkdir -p "${BATS_TEST_DIRNAME}/libexec"
  cat >"${BATS_TEST_DIRNAME}/libexec/jlenv-which" <<OUT
#!/bin/sh
echo /bin/julia
OUT
  chmod +x "${BATS_TEST_DIRNAME}/libexec/jlenv-which"
  JLENV_VERSION="system" run jlenv-prefix
  assert_success "/"
  rm -f "${BATS_TEST_DIRNAME}/libexec/jlenv-which"
}

@test "prefix for invalid system" {
  PATH="$(path_without julia)" run jlenv-prefix system
  assert_failure "jlenv: system version not found in PATH"
}
