#!/bin/zsh

export FZF_DEFAULT_OPTS="--extended --cycle --tac --ansi --multi --prompt='-➜ '"
if [[ "$TERM_PROGRAM" = "Apple_Terminal" ]]; then
  COLOR_BLACK=0
  COLOR_GREEN=2
  COLOR_BLUE=4
  COLOR_WHITE=7
else
  COLOR_BLACK="#000000"
  COLOR_GREEN="#00ffd8"
  COLOR_BLUE="#09e7fb"
  COLOR_WHITE="#ffffff"
fi
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
--color fg:$COLOR_WHITE,fg+:$COLOR_GREEN
--color bg:$COLOR_BLACK,bg+:$COLOR_BLACK
--color hl:$COLOR_GREEN,hl+:$COLOR_GREEN
--color pointer:$COLOR_BLUE,marker:$COLOR_GREEN,spinner:$COLOR_BLUE
--color info:$COLOR_GREEN,prompt:$COLOR_BLUE,header:$COLOR_WHITE"
export TOMOCY_FD_DEFAULT_COMMAND_OPTS=(--hidden --follow --exclude .git)
export FZF_DEFAULT_COMMAND="fd ${TOMOCY_FD_DEFAULT_COMMAND_OPTS[*]} . ."

_fzf_compgen_path() {
  fd "${TOMOCY_FD_DEFAULT_COMMAND_OPTS[@]}" . "$1"
}

_fzf_compgen_dir() {
  fd --type d "${TOMOCY_FD_DEFAULT_COMMAND_OPTS[@]}" . "$1"
}

_f() {
  local fd
  fd="fd ${TOMOCY_FD_DEFAULT_COMMAND_OPTS[*]} ${*:2}"
  local arg
  arg=$(eval "$fd" | fzf) &&
    test -n "$arg" &&
    print -z -- "$1 $arg"
}

_fccd() {
  local args
  args=$(echo "$@" | awk '{gsub("-t [a-zA-Z]|--type [a-zA-Z]", "", $0);print $0}' | xargs) &&
    _f cd "$args --type d . ."
}

_fcpd() {
  local dirs=()
  get_parent_dirs() {
    if [[ -d "$1" ]]; then
      dirs+=("$1")
    else
      return
    fi

    if [[ $1 == '/' ]]; then
      for dir in "${dirs[@]}"; do
        echo "$dir"
      done | tac
    else
      get_parent_dirs "$(dirname "$1")"
    fi
  }

  local dir
  dir=$(get_parent_dirs "$(realpath "${1:-$PWD}")" | fzf) &&
    print -z -- "cd $dir"
}

_fcd() {
  if [[ $1 == '..' ]]; then
    _fcpd "$@"
  else
    _fccd "$@"
  fi
}

_fgitcheckout() {
  local branches
  local branch
  branches=$(git branch | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf +m) &&
    test -n "$branch" &&
    git checkout "${branch//.* /}"
}

_fgitshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << FZF-EOF
{}
FZF-EOF"
}

_fgit() {
  local cmd="_fgit$1"
  if type "$cmd" > /dev/null 2>&1; then
    $cmd "${@:2}"
  fi
}

_fhistory() {
  print -z -- "$(history "$@" | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')"
}

_fpreview() {
  fd --type f "${TOMOCY_FD_DEFAULT_COMMAND_OPTS[@]}" | fzf --preview 'head -n 100 {}'
}

f() {
  local cmd="_f$1"
  if type "$cmd" > /dev/null 2>&1; then
    $cmd "${@:2}"
  else
    _f "$@"
  fi
}

_fcomplete() {
  _arguments \
    {-t,--type}'[type to search]' \
    {-d,--max-depth}'[max depth to search in]' \
    '*: :->cmd'

  case ${state?} in
  cmd)
    _alternative "f:f:_sudo"
    ;;
  esac
}

compdef _fcomplete f
