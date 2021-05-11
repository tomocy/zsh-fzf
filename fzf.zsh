#!/bin/bash

export FZF_DEFAULT_OPTS="--extended --cycle --tac --ansi --prompt='-➜ '"
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

alias fcat="fzf --preview 'bat $BAT_DEFAULT_OPTS {}'"

fsrc() {
  local dir
  dir=$(fd -t d . ~/Codes/src | fzf)
  [[ -n "$dir" ]] && print -z "cd $dir"
}

ftomocy() {
  local dir
  dir=$(fd -t d . ~/Codes/src/github.com/tomocy | fzf)
  [[ -n "$dir" ]] && print -z "cd $dir"
}

fcode() {
  local dir
  dir=$(fd -t d . ~/Codes/src | fzf)
  [[ -n "$dir" ]] && print -z "code $dir"
}

fadd() {
  local files
  files=$(git ls-files --deleted --modified --others --exclude-standard | fcat --multi)
  files=$(printf "$files" | tr '\n' ' ')
  [[ -n "$files" ]] && print -z "git add $files"
}

fshow() {
  git log --color=always --pretty=format:"%C(auto)%h%d %s %C(black)%C(bold)%cr" |
    fzf --preview 'echo {} | awk '"'"'{print $1}'"'"' | xargs git show --color=always' |
    awk '{print $1}'
}

frebase() {
  local chash
  chash=$(fshow)
  [[ -n "$chash" ]] && print -z "git rebase -i $chash"
}
