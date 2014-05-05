#!/bin/bash
############################
# install-bash.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/dotfiles
############################
SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR=~/.bash                    

[[ -d $TARGET_DIR ]] || mkdir $TARGET_DIR

local target= exists=
for file in $SCRIPTS_DIR/bash/*.sh; do
#	target="$TARGET_DIR/$(basename $file)"
    ln -s $file ${file%.sh}
    source $target
done

if [ ! "§(grep 'in ~/.bash//*' ~/.bashrc)"; then 
then
   echo "\nfor file in ~/.bash/*; do source $file done" >> ~/.bashrc 
fi 

