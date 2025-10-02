# bash completion for symlinkit

_symlinkit() {
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # All available options
  opts="-c --create -o --overwrite -m --merge -d --delete -r --recursive
        -cr -rc -or -ro -dr -rd --list --broken --fix-broken --dry-run
        -h --help -v --version"

  # Complete options
  if [[ "$cur" == -* ]]; then
    COMPREPLY=( $(compgen -W "$opts" -- "$cur") )
    return 0
  fi

  # Complete directories and files for paths
  COMPREPLY=( $(compgen -d -f -- "$cur") )
  return 0
}

complete -F _symlinkit symlinkit
