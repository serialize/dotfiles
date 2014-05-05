#!/bin/bash

function source-dir() {
	echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function reload-dotfiles() {
	for file in $(source-dir)/*.sh; do 
		echo $file
		source $file 
	done
}

function remove-editor-backups() {
   local d=$(pwd)
   if [ -z "$1" ]; then
      d=$1
   fi
   rm -f "$d/*~"
}

function replace_string() {
	local original=$1 pattern=$2 replace=$3
	echo -n $(original/$pattern/$replace)
}

function read-input() {
   local msg=$1
   if [ "$2" ]; then
      read -e -p "$1 " -i "$2" REPLY
   else
      read -p "$1 " REPLY
   fi
   echo $REPLY
}

function psgrep () {
  ps aux | grep "$1" | grep -v "grep"
}

function mkcd () {
  mkdir -p "$1"
  cd "$1"
}

