#!/bin/zsh

set -eu

_fcd() {
    local opt
    local maxdepth_opt='-maxdepth 1'
    while getopts ad: opt
    do
        case $opt in
            a) maxdepth_opt='';;
            d) maxdepth_opt="-maxdepth $OPTARG";;
        esac
    done

    local dir=$(find * $(echo $maxdepth_opt) -type d -print 2> /dev/null | fzf-tmux) && cd "$dir"
}

_fcpd() {
  local declare dirs=()
  get_parent_dirs() {
    if [[ -d "$1" ]]
    then
        dirs+=($1)
    else 
        return
    fi

    if [[ "$1" == '/' ]]
    then
        for _dir in ${dirs[@]}
        do
            echo $_dir
        done
    else
        get_parent_dirs $(dirname $1)
    fi
  }

  local dir=$(get_parent_dirs $(realpath ${1:-$PWD}) | fzf-tmux --tac) && cd "$dir"
}


fcd() {
    set +u
    if [[ $1 == '..' ]]
    then
        _fcpd
    else
        _fcd $@
    fi
    set -u
}