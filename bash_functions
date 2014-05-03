#!/bin/bash

function psgrep () {
  ps aux | grep "$1" | grep -v "grep"
}

function mkcd () {
  mkdir -p "$1"
  cd "$1"
}

function _ps1_color() {
   printf "%s%s$NC" $1 $2 
}
function _ps1_sys() {
   local user=$(_ps1_color $white "\u@\h")
   local path=$(_ps1_color $blue "\w")
   echo -en $user:$path
}
function _ps1_git() {
   local gitbranch="$(git_get_branch_name)"
   if [ "$gitbranch" ]; then
      local gitcounts="$(git_get_count_mod)"
      gitcounts+="$(git_get_count_new)"
      gitcounts+="$(git_get_count_del)"
      echo -en $SYM_2$SYM_2[
      echo -en $(_ps1_color $yellow "$gitbranch")
      echo -en "-"
      echo -en $(_ps1_color $yellow "$gitcounts")
      echo -en ]$SYM_2
   else
      echo -en $SYM_2$SYM_2$SYM_2
   fi   
}

function ps1_compile() {
   echo -e $SYM_1$SYM_2$(_ps1_sys)
   echo -en $SYM_3'$(_ps1_git)'
   echo -en $SYM_7"\x20"
}

function read_input() {
   local msg=$1
   if [ "$2" ]; then
      read -e -p "$1 " -i "$2" REPLY
   else
      read -p "$1 " REPLY
   fi
   echo $REPLY
}

function ssh_keygen() {
   local hostalias=$(read_input "hostalias:")
   local server=$(read_input "hostname:")
   local port=$(read_input "port:" "22")
   local user=$(read_input "user:")
   
   local copy_key=$(read_input "Copy public key to remote host?" "yes")
   local write_config=$(read_input "Write config?" "yes")
   local add_agent=$(read_input "Add key to agent?" "yes")
   local remove_key=$(read_input "Remove public key?" "yes")

   local key=/home/$(whoami)/.ssh/.keys/id_$hostalias
   local config=/home/$(whoami)/.ssh/config
   local serverlogin=$user@$server
   local comment="$(whoami)@$(hostname)_$(date -I)"
   
   ssh-keygen -t rsa -b 4096 -C $comment -f $key
   if [ "$copy_key" == "yes" ]; then
	   ssh-copy-id -i $key -p $port $serverlogin
   fi
   if [ "$write_config" == "yes" ]; then
      echo "Writing config file."
	   echo "Host $hostalias" >> $config
	   echo "	Hostname $server" >> $config
	   echo "	Port $port" >> $config
	   echo "	User $user" >> $config
	   echo "	IdentityFile $key" >> $config
   fi
   if [ "$add_agent" == "yes" ]; then
	   ssh-add $key
   fi
   if [ "$remove_key" == "yes" ]; then
      echo "Removing public key."
	   rm -f $key.pub
   fi
   
}

