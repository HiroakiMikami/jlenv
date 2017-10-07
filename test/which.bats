#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin
  if [[ $1 == */* ]]; then bin="$1"
  else bin="${JLENV_ROOT}/versions/${1}/bin"
  fi
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "outputs path to executable" {
  create_executable "1.8" "ruby"
  create_executable "2.0" "rspec"

  JLENV_VERSION=1.8 run jlenv-which ruby
  assert_success "${JLENV_ROOT}/versions/1.8/bin/ruby"

  JLENV_VERSION=2.0 run jlenv-which rspec
  assert_success "${JLENV_ROOT}/versions/2.0/bin/rspec"
}

@test "searches PATH for system version" {
  create_executable "${JLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${JLENV_ROOT}/shims" "kill-all-humans"

  JLENV_VERSION=system run jlenv-which kill-all-humans
  assert_success "${JLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims prepended)" {
  create_executable "${JLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${JLENV_ROOT}/shims" "kill-all-humans"

  PATH="${JLENV_ROOT}/shims:$PATH" JLENV_VERSION=system run jlenv-which kill-all-humans
  assert_success "${JLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims appended)" {
  create_executable "${JLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${JLENV_ROOT}/shims" "kill-all-humans"

  PATH="$PATH:${JLENV_ROOT}/shims" JLENV_VERSION=system run jlenv-which kill-all-humans
  assert_success "${JLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "searches PATH for system version (shims spread)" {
  create_executable "${JLENV_TEST_DIR}/bin" "kill-all-humans"
  create_executable "${JLENV_ROOT}/shims" "kill-all-humans"

  PATH="${JLENV_ROOT}/shims:${JLENV_ROOT}/shims:/tmp/non-existent:$PATH:${JLENV_ROOT}/shims" \
    JLENV_VERSION=system run jlenv-which kill-all-humans
  assert_success "${JLENV_TEST_DIR}/bin/kill-all-humans"
}

@test "doesn't include current directory in PATH search" {
  export PATH="$(path_without "kill-all-humans")"
  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"
  touch kill-all-humans
  chmod +x kill-all-humans
  JLENV_VERSION=system run jlenv-which kill-all-humans
  assert_failure "jlenv: kill-all-humans: command not found"
}

@test "version not installed" {
  create_executable "2.0" "rspec"
  JLENV_VERSION=1.9 run jlenv-which rspec
  assert_failure "jlenv: version \`1.9' is not installed (set by JLENV_VERSION environment variable)"
}

@test "no executable found" {
  create_executable "1.8" "rspec"
  JLENV_VERSION=1.8 run jlenv-which rake
  assert_failure "jlenv: rake: command not found"
}

@test "no executable found for system version" {
  export PATH="$(path_without "rake")"
  JLENV_VERSION=system run jlenv-which rake
  assert_failure "jlenv: rake: command not found"
}

@test "executable found in other versions" {
  create_executable "1.8" "ruby"
  create_executable "1.9" "rspec"
  create_executable "2.0" "rspec"

  JLENV_VERSION=1.8 run jlenv-which rspec
  assert_failure
  assert_output <<OUT
jlenv: rspec: command not found

The \`rspec' command exists in these Ruby versions:
  1.9
  2.0
OUT
}

@test "carries original IFS within hooks" {
  create_hook which hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' JLENV_VERSION=system run jlenv-which anything
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "discovers version from jlenv-version-name" {
  mkdir -p "$JLENV_ROOT"
  cat > "${JLENV_ROOT}/version" <<<"1.8"
  create_executable "1.8" "ruby"

  mkdir -p "$JLENV_TEST_DIR"
  cd "$JLENV_TEST_DIR"

  JLENV_VERSION= run jlenv-which ruby
  assert_success "${JLENV_ROOT}/versions/1.8/bin/ruby"
}
