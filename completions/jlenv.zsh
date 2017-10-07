if [[ ! -o interactive ]]; then
    return
fi

compctl -K _jlenv jlenv

_jlenv() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(jlenv commands)"
  else
    completions="$(jlenv completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}
