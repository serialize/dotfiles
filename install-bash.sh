#!/bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# install-bash.sh
# This script creates symlinks from the home directory 
# to any desired dotfiles in ~/dotfiles
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR=~/.bash                    
function prepare() {
	[[ -d $TARGET_DIR ]] || mkdir $TARGET_DIR
}

function copy_files() {
	local target= exists=
   rm -f $TARGET_DIR/*
	for file in $SCRIPTS_DIR/bash/*.sh; do
		target="$TARGET_DIR/$(basename $file)"
		target=${target%.sh}
		ln -s $file $target 
	   source $target
	done
}

function setup_bashrc() {
	if [[ ! "$(grep 'source ~/.bash//*' ~/.bashrc)" ]]; then 
	   echo -e "source ~/.bash/*" >> ~/.bashrc 
   fi 
}

prepare
copy_files
setup_bashrc
