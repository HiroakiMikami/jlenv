#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run jlenv-help
  assert_success
  assert_line "Usage: jlenv <command> [<args>]"
  assert_line "Some useful jlenv commands are:"
}

@test "invalid command" {
  run jlenv-help hello
  assert_failure "jlenv: no such command \`hello'"
}

@test "shows help for a specific command" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  cat > "${JLENV_TEST_DIR}/bin/jlenv-hello" <<SH
#!shebang
# Usage: jlenv hello <world>
# Summary: Says "hello" to you, from jlenv
# This command is useful for saying hello.
echo hello
SH

  run jlenv-help hello
  assert_success
  assert_output <<SH
Usage: jlenv hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  cat > "${JLENV_TEST_DIR}/bin/jlenv-hello" <<SH
#!shebang
# Usage: jlenv hello <world>
# Summary: Says "hello" to you, from jlenv
echo hello
SH

  run jlenv-help hello
  assert_success
  assert_output <<SH
Usage: jlenv hello <world>

Says "hello" to you, from jlenv
SH
}

@test "extracts only usage" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  cat > "${JLENV_TEST_DIR}/bin/jlenv-hello" <<SH
#!shebang
# Usage: jlenv hello <world>
# Summary: Says "hello" to you, from jlenv
# This extended help won't be shown.
echo hello
SH

  run jlenv-help --usage hello
  assert_success "Usage: jlenv hello <world>"
}

@test "multiline usage section" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  cat > "${JLENV_TEST_DIR}/bin/jlenv-hello" <<SH
#!shebang
# Usage: jlenv hello <world>
#        jlenv hi [everybody]
#        jlenv hola --translate
# Summary: Says "hello" to you, from jlenv
# Help text.
echo hello
SH

  run jlenv-help hello
  assert_success
  assert_output <<SH
Usage: jlenv hello <world>
       jlenv hi [everybody]
       jlenv hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  mkdir -p "${JLENV_TEST_DIR}/bin"
  cat > "${JLENV_TEST_DIR}/bin/jlenv-hello" <<SH
#!shebang
# Usage: jlenv hello <world>
# Summary: Says "hello" to you, from jlenv
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run jlenv-help hello
  assert_success
  assert_output <<SH
Usage: jlenv hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}
