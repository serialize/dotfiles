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
   branch+=$(git-info-branch-name 2> /dev/null)
   [[ "$branch" ]] || return 0
   export GIT_CURRENT_BRANCH="$branch"
   export GIT_CURRENT_COUNT_MOD=$(git-info-count-modified 2> /dev/null)
   export GIT_CURRENT_COUNT_NEW=$(git-info-count-new 2> /dev/null)
   export GIT_CURRENT_COUNT_DEL=$(git-info-count-deleted 2> /dev/null)
}

function git-push() {
	git push
}

function git-push() {
	git pull
}

function git-info-branch-name() {
	echo -en $(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
}

function git-info-count-modified() {
	echo -en $(git status 2> /dev/null | grep 'modified:' | grep -v untracked | wc -l)
}
function git-info-count-new() {
	echo -en $(git status 2> /dev/null | grep 'new file' | wc -l)
}
function git-info-count-deleted() {
	echo -en $(git status 2> /dev/null | grep 'deleted' | wc -l)
}
