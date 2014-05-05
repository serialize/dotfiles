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
	export GIT_CURRENT_BRANCH=$(git-info-branch-name)
	export GIT_CURRENT_COUNT_MOD=$(git-info-count-modified)
	export GIT_CURRENT_COUNT_NEW=$(git-info-count-new)
	export GIT_CURRENT_COUNT_DEL=$(git-info-count-deleted)
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
	echo -en $(git-info-modified | grep -v untracked | wc -l)
}
function git-info-modified() {
	echo -en $(git status 2> /dev/null | grep 'modified:')
}

function git-info-count-new() {
	echo -en $(git-info-new | wc -l)
}
function git-info-new() {
	echo -en $(git status 2> /dev/null | grep 'new file')
}

function git-info-count-deleted() {
	echo -en $(git-info-deleted | wc -l)
}
function git-info-deleted() {
	echo -en $(git status 2> /dev/null | grep 'deleted')
}




