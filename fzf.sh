#!/bin/zsh

ffind() {
    local maxdepth_opt='-maxdepth 1'
    local type_opt
    while getopts d:t: opt
    do
        case $opt in
            d) maxdepth_opt="-maxdepth $OPTARG";;
            t) type_opt="-type $OPTARG";;
        esac
    done

    echo "$(find * $(echo $maxdepth_opt) $(echo $type_opt) -print 2> /dev/null | fzf-tmux)"
}

_fcd() {
    local dir=$(ffind $(echo $maxdepth_opt) -t d) && cd "$dir"
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
    if [[ $1 == '..' ]]
    then
        _fcpd
    else
        _fcd $@
    fi
}