#!/bin/bash

source bash_colors
source bash_variables
source bash_commands

function psgrep () {
  ps aux | grep "$1" | grep -v "grep"
}

function mkcd () {
  mkdir -p "$1"
  cd "$1"
}


git_parse_branch() {
   local branch=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
   echo $branch
   if [ $branch ]; then
      declare -a git=($branch)
      git[1]=`git status 2> /dev/null | grep "modified:" | grep -v untracked | wc -l`
      git[2]=`git status 2> /dev/null | grep "new file" | wc -l`
      git[3]=`git status 2> /dev/null | grep "deleted" | wc -l`
      echo ${git[@]}
      unset git
   fi
}
_ps1_format_sys() {
   echo -en $white
   echo -en "\u@\h:"
   echo -en $blue
   echo -en "\w"
   echo -en $NC
}
_ps1_format_git() {
   local name=$cmd_git_get_branch #$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
   if [ "$name" ]; then
      local mod=$cmd_git_get_count_mod #$(git status 2> /dev/null | grep "modified:" | grep -v untracked | wc -l)
      local new=$cmd_git_get_count_new #$(git status 2> /dev/null | grep "new file" | wc -l)
      local del=$cmd_git_get_count_del #$(git status 2> /dev/null | grep "deleted" | wc -l)
      
      echo -en $cyan
      echo -en "$name "   #\xe2\x86\x92 "

      echo -en $yellow
      echo -en "\xe2\x9d\x8d$mod "
      echo -en "\xe2\x9c\xb7$new "
      echo -en "\xe2\x9c\x9d$del"
      
      echo -en $NC
   fi
}
_ps1_format_git_2() {
   local name=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
   if [ "$name" ]; then
      local mod=$(git status 2> /dev/null | grep "modified:" | grep -v untracked | wc -l)
      local new=$(git status 2> /dev/null | grep "new file" | wc -l)
      local del=$(git status 2> /dev/null | grep "deleted" | wc -l)
      
      echo -en $cyan
      echo -en "$name"   #\xe2\x86\x92 "
      #echo -en "$name "   #\xe2\x86\x92 "

      echo -en $NC
      echo -en '\xe2\x8a\xa2'
      echo -en '\xe2\x8a\xa3'

      echo -en $yellow
      echo -en $mod
      echo -en $new
      echo -en $del
      #echo -en "\xe2\x9d\x8d$mod "
      #echo -en "\xe2\x9c\xb7$new "
      #echo -en "\xe2\x9c\x9d$del"
      
      echo -en $NC
   fi
}
ps1_format() {
   echo -en '\xe2\x94\x8c'
   #echo -en '\xe2\x94\x80'
   echo -en '\x20'
   echo -en $(_ps1_format_sys) 
   echo -en '\n'
   
   local git=$(_ps1_format_git)
   if [ "$git" ];then
      echo -en '\xe2\x94\x82'
      echo -en '\x20'
      echo -en $git
      echo -en '\n'
   fi
   
   echo -en '\xe2\x94\x94'
   #echo -en '\xe2\x94\x80'
   echo -en '\xe2\x95\xbc '
}

ps1_format_2() {
   echo -en '\xe2\x94\x8c'
   #echo -en '\xe2\x94\x80'
   #echo -en '\x20'
   echo -en $(_ps1_format_sys) 
   echo -en '\n'
   
   echo -en '\xe2\x94\x94'
   #echo -en '\xe2\x94\x80'
   local git=$(_ps1_format_git_2)
   if [ "$git" ];then
      #echo -en '\xe2\x94\x82'
      #echo -en '\x20'
      #echo -en '['
      echo -en '\xe2\x8a\xa3'
      echo -en $git
      echo -en '\xe2\x8a\xa2'
      #echo -en '\xe2\x94\x82'
      #echo -en ']'
      #echo -en '\x20'
   else
      echo -en '\xe2\x94\x80'
      echo -en '\xe2\x94\x80'
   fi
   echo -en '\xe2\x95\xbc'
   echo -en '\x20'
}

_ps1_format() {
   declare -a prefix=('\xe2\x94\x8c\xe2\x94\x80' '\xe2\x94\x82\xe2' '\xe2\x94\x94\xe2\x94\x80\xe2\x94\x80\xe2\x95\xbc\x20');
   echo -en "$GREEN"
   echo -en "${prefix[0]}"
   echo " $white\u@\h:$blue\w$NC"
   local git=$(git_parse_branch)
   if [ $git ]; then
      echo -en "$GREEN${prefix[1]}" 
      declare -a symbols=('\xe2\x86\x92' '\xe2\x9d\x8d' '\xe2\x9d\x8d' '\xe2\x9d\x8d');
      symbols[0]="$1 ${symbols[0]}"
      echo -en " $GREEN${symbols[0]} "
      symbols[1]+=${2:-0}
      symbols[2]+=${3:-0}
      symbols[3]+=${4:-0}
      printf "$yellow%s %s %s$NC\n" ${symbols[@]:1:3}
      unset symbols
   fi
   echo -en "$GREEN${prefix[2]}$NC "
   unset prefix
}

ssh_keygen() {
   read -p "hostalias: " 
   local host="$REPLY"

   read -p "hostname: "
   local server="$REPLY"

   local port_default=22
   read -p "port [$port_default]: " port
   local port="${port:-$port_default}"

   read -p "user: "
   local user="$REPLY"

   local key="/home/$(whoami)/.ssh/.keys/id_$host"
   local config="/home/$(whoami)/.ssh/config"
   local serverlogin="$user@$server"
   local comment="$(whoami)@$(server)_$(date -I)"

   local param="-t rsa -b 4096 -C \"$comment\" -f $key"
   ssh-keygen $param

   local copy_key_default="Y"
   read -p "Copy public key to remote host? [Y]: " copy_key
   local copy_key="${copy_key:-$copy_key_default}"
   if [ "$copy_key" == "y" ] || [ "$copy_key" == "Y" ]; then
	   param="-i $key -p $port $serverlogin"
	   ssh-copy-id $param
   fi

   local write_config_default="Y"
   read -p "Write config? [Y]: " write_config
   local write_config="${write_config:-$write_config_default}"
   if [ "$write_config" == "y" ] || [ "$write_config" == "Y" ]; then
	   echo "Host $host" >> $config
	   echo "	Hostname $server" >> $config
	   echo "	Port $port" >> $config
	   echo "	User $user" >> $config
	   echo "	IdentityFile $key" >> $config
   fi

   local add_key_default="Y"
   read -p "Add key to agent? [Y]: " add_key
   local ADD_key="${add_key:-$add_key_default}"
   if [ "$add_key" == "y" ] || [ "$add_key" == "Y" ]; then
	   ssh-add $key
   fi

   local remove_key_default="Y"
   read -p "Remove public key? [Y]: " remove_key
   local remove_key="${remove_key:-$remove_key_default}"
   if [ "$remove_key" == "y" ] || [ "$remove_key" == "Y" ]; then
	   rm -f $key.pub
   fi

}
