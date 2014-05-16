#!/bin/bash
alias gips="git-push"
alias gipl="git-pull"
alias gipad="git-parse-current-dir"
alias giib="git-info-branch-name"
alias giicm="git-info-count-modified"
alias giim="git-info-modified"
alias giicn="git-info-count-new"
alias giin="git-info-new"
alias giicd="git-info-count-deleted"
alias giid="git-info-deleted"

function git-parse-current-dir() {
   #echo -en "git-parse\n"
   export TIMESTAMP=$(date)
   
   unset GIT_CURRENT_BRANCH
   unset GIT_CURRENT_COUNT_MOD
   unset GIT_CURRENT_COUNT_NEW
   unset GIT_CURRENT_COUNT_DEL
   local branch=
   branch+=$(git-status-branch-name 2> /dev/null)
   [[ "$branch" ]] || return 0
   export GIT_CURRENT_BRANCH="$branch"
   export GIT_CURRENT_COUNT_MOD=$(git-status-count-modified 2> /dev/null)
   export GIT_CURRENT_COUNT_NEW=$(git-status-count-new 2> /dev/null)
   export GIT_CURRENT_COUNT_DEL=$(git-status-count-deleted 2> /dev/null)
}

function git-push() {
	git push
}

function git-push() {
	git pull
}

function git-status-branch-name() {
	echo -en $(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
}

function git-status-count-modified() {
	echo -en $(git status 2> /dev/null | grep 'modified:' | grep -v untracked | wc -l)
}
function git-status-count-new() {
	echo -en $(git status 2> /dev/null | grep 'new file' | wc -l)
}
function git-status-count-deleted() {
	echo -en $(git status 2> /dev/null | grep 'deleted' | wc -l)
}
export git_unt=0

function git-status-counts() {
   local status=$(git status -s 2> /dev/null) mod=0 new=0 del=0 unt=0
   echo "$status" | while read line; do
      local ident=${line:0:2} left=${line:0:1}  right=${line:1:1}
      if [[ ${line:1:1}=="M" ]];then
         echo "$ident $left $right"
         ((unt+=1)) 
         echo "unt: $unt"
      fi
   done
   export git_unt="$unt"
   echo "untracked: $git_unt $unt"
}

