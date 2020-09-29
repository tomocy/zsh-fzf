#!/bin/zsh

export FZF_DEFAULT_OPTS="--extended --cycle --tac --ansi --multi"
export TOMOCY_FZF_DEFAULT_COMMAND_OPTS='--hidden --follow --exclude .git'
export FZF_DEFAULT_COMMAND='fd --type f $TOMOCY_FZF_DEFAULT_COMMAND_OPTS'

_fzf_compgen_path() {
  fd $(echo $TOMOCY_FZF_DEFAULT_COMMAND_OPTS) . "$1"
}

_fzf_compgen_dir() {
  fd --type d $(echo $TOMOCY_FZF_DEFAULT_COMMAND_OPTS) . "$1"
}

f() {
    local arg=$(fd $(echo $TOMOCY_FZF_DEFAULT_COMMAND_OPTS) ${@:2} | fzf) && test -n "$arg" && 
    print -z -- "$1 $arg"
}

_fcd() {
    local args=$(echo "$@" | awk '{gsub("-t [a-zA-Z]|--type [a-zA-Z]", "", $0);print $0}' | xargs) &&
    f cd $(echo $args) --type d
}

_fcpd() {
  local dirs=()
  get_parent_dirs() {
    if [[ -d "$1" ]]
    then
        dirs+=($1)
    else 
        return
    fi

    if [[ $1 == '/' ]]
    then
        for dir in ${dirs[@]}
        do
            echo $dir
        done | tac
    else
        get_parent_dirs $(dirname $1)
    fi
  }

  local dir=$(get_parent_dirs $(realpath ${1:-$PWD}) | fzf) && 
  cd $dir
}


fcd() {
    if [[ $1 == '..' ]]
    then
        _fcpd
    else
        _fcd $@
    fi
}

fhistory() {
    print -z -- "$(history $@ | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')"
}

fgit() {
    local $args=${@:2}
    if [[ $1 == 'checkout' ]]
    then
        _fgitcheckout $args
    elif [[ $1 == 'show' ]]
    then
        _fgitshow $args
    fi
}

_fgitcheckout() {
  local branches=$(git branch --all | grep -v HEAD) &&
  local branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

_fgitshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
        --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}