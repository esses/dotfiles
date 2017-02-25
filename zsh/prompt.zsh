#!/usr/bin/env zsh
#local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

setopt promptsubst
autoload colors && colors

if (( $+commands[git] ))
then
  git="$commands[git]"
else
  git="/usr/bin/git"
fi

git_branch() {
  echo $($git symbolic-ref HEAD 2>/dev/null | awk -F/ {'print $NF'})
}

git_dirty() {
  if $(! $git status -s &> /dev/null)
  then
    echo ""
  else
    if [[ $($git status --porcelain) == "" ]]
    then
      echo "(%{$fg_bold[green]%}$(git_prompt_info)%{$reset_color%})"
    else
      echo "(%{$fg_bold[red]%}$(git_prompt_info)%{$reset_color%})"
    fi
  fi
}

git_prompt_info () {
 ref=$($git symbolic-ref HEAD 2>/dev/null) || return
# echo "(%{\e[0;33m%}${ref#refs/heads/}%{\e[0m%})"
 echo "${ref#refs/heads/}"
}

unpushed () {
  $git cherry -v @{upstream} 2>/dev/null
}

need_push () {
  if [[ $(unpushed) == "" ]]
  then
    echo " "
  else
    echo " with %{$fg_bold[magenta]%}unpushed%{$reset_color%} "
  fi
}

node_version() {
  if (( $+commands[node] ))
  then
    echo "$(node -v | awk '{print $1}')"
  fi
}

node_prompt() {
  if ! [[ -z "$(node_version)" ]] && [[ -e ./package.json ]]
  then
    echo "%{$fg_bold[cyan]%}node $(node_version)%{$reset_color%}"
  else
    echo ""
  fi
}

directory_name() {
  echo "%{$fg_bold[cyan]%}%~%{$reset_color%}"
}

export PROMPT=$'\n$(directory_name) $(git_dirty)$(need_push)\n⚡ '

set_right_prompt() {
  export RPROMPT="$(node_prompt)%{$fg_bold[cyan]%}%{$reset_color%}"
}

precmd() {
  # check versions on prompt load
  set_right_prompt

  # set working dir to title
  echo -ne "\e]1;${PWD##*/}\a"
}

case $TERM in 
  xterm*)
    precmd() {
      print -Pn "\e]0;${PWD##*/}\a"
    }
    ;;
esac
