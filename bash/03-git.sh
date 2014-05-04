#!/bin/bash
alias gips="git-push"
alias giib="git-info-branch-name"
alias giicm="git-info-count-modified"
alias giim="git-info-modified"
alias giicn="git-info-count-new"
alias giin="git-info-new"
alias giicd="git-info-count-deleted"
alias giid="git-info-deleted"

function git-push() {
	git push
}

function git-info-branch-name() {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git-info-count-modified() {
	$(git-info-count-modified) | grep -v untracked | wc -l
}
function git-info-modified() {
	git status 2> /dev/null | grep 'modified:'
}

function git-info-count-new() {
	$(git-info-count-new) | wc -l
}
function git-info-new() {
	git status 2> /dev/null | grep 'new file'
}

function git-info-count-deleted() {
	$(git-info-count-deleted) | wc -l
}
function git-info-deleted() {
	git status 2> /dev/null | grep 'deleted'
}




