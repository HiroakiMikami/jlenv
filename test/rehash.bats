#!/usr/bin/env bats

load test_helper

create_executable() {
  local bin="${JLENV_ROOT}/versions/${1}/bin"
  mkdir -p "$bin"
  touch "${bin}/$2"
  chmod +x "${bin}/$2"
}

@test "empty rehash" {
  assert [ ! -d "${JLENV_ROOT}/shims" ]
  run jlenv-rehash
  assert_success ""
  assert [ -d "${JLENV_ROOT}/shims" ]
  rmdir "${JLENV_ROOT}/shims"
}

@test "non-writable shims directory" {
  mkdir -p "${JLENV_ROOT}/shims"
  chmod -w "${JLENV_ROOT}/shims"
  run jlenv-rehash
  assert_failure "jlenv: cannot rehash: ${JLENV_ROOT}/shims isn't writable"
}

@test "rehash in progress" {
  mkdir -p "${JLENV_ROOT}/shims"
  touch "${JLENV_ROOT}/shims/.jlenv-shim"
  run jlenv-rehash
  assert_failure "jlenv: cannot rehash: ${JLENV_ROOT}/shims/.jlenv-shim exists"
}

@test "creates shims" {
  create_executable "1.8" "julia"
  create_executable "2.0" "julia"

  assert [ ! -e "${JLENV_ROOT}/shims/julia" ]

  run jlenv-rehash
  assert_success ""

  run ls "${JLENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
julia
OUT
}

@test "removes outdated shims" {
  mkdir -p "${JLENV_ROOT}/shims"
  touch "${JLENV_ROOT}/shims/oldshim1"
  chmod +x "${JLENV_ROOT}/shims/oldshim1"

  create_executable "2.0" "rake"
  create_executable "2.0" "julia"

  run jlenv-rehash
  assert_success ""

  assert [ ! -e "${JLENV_ROOT}/shims/oldshim1" ]
}

@test "do exact matches when removing stale shims" {
  create_executable "2.0" "unicorn_rails"
  create_executable "2.0" "rspec-core"

  jlenv-rehash

  cp "$JLENV_ROOT"/shims/{rspec-core,rspec}
  cp "$JLENV_ROOT"/shims/{rspec-core,rails}
  cp "$JLENV_ROOT"/shims/{rspec-core,uni}
  chmod +x "$JLENV_ROOT"/shims/{rspec,rails,uni}

  run jlenv-rehash
  assert_success ""

  assert [ ! -e "${JLENV_ROOT}/shims/rails" ]
  assert [ ! -e "${JLENV_ROOT}/shims/rake" ]
  assert [ ! -e "${JLENV_ROOT}/shims/uni" ]
}

@test "binary install locations containing spaces" {
  create_executable "dirname1 p247" "julia"

  assert [ ! -e "${JLENV_ROOT}/shims/julia" ]

  run jlenv-rehash
  assert_success ""

  run ls "${JLENV_ROOT}/shims"
  assert_success
  assert_output <<OUT
julia
OUT
}

@test "carries original IFS within hooks" {
  create_hook rehash hello.bash <<SH
hellos=(\$(printf "hello\\tugly world\\nagain"))
echo HELLO="\$(printf ":%s" "\${hellos[@]}")"
exit
SH

  IFS=$' \t\n' run jlenv-rehash
  assert_success
  assert_output "HELLO=:hello:ugly:world:again"
}

@test "sh-rehash in bash" {
  create_executable "2.0" "julia"
  JLENV_SHELL=bash run jlenv-sh-rehash
  assert_success "hash -r 2>/dev/null || true"
  assert [ -x "${JLENV_ROOT}/shims/julia" ]
}

@test "sh-rehash in fish" {
  create_executable "2.0" "julia"
  JLENV_SHELL=fish run jlenv-sh-rehash
  assert_success ""
  assert [ -x "${JLENV_ROOT}/shims/julia" ]
}
