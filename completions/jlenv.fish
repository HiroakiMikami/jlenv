function __fish_jlenv_needs_command
  set cmd (commandline -opc)
  if [ (count $cmd) -eq 1 -a $cmd[1] = 'jlenv' ]
    return 0
  end
  return 1
end

function __fish_jlenv_using_command
  set cmd (commandline -opc)
  if [ (count $cmd) -gt 1 ]
    if [ $argv[1] = $cmd[2] ]
      return 0
    end
  end
  return 1
end

complete -f -c jlenv -n '__fish_jlenv_needs_command' -a '(jlenv commands)'
for cmd in (jlenv commands)
  complete -f -c jlenv -n "__fish_jlenv_using_command $cmd" -a "(jlenv completions $cmd)"
end
