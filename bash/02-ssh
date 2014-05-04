#!/bin/bash
alias ssh-gk="ssh-generate-key"

function ssh-generate-key() {
   local hostalias=$(read-input "hostalias:")
   local server=$(read-input "hostname:")
   local port=$(read-input "port:" "22")
   local user=$(read-input "user:")
   
   local copy_key=$(read-input "Copy public key to remote host?" "yes")
   local write_config=$(read-input "Write config?" "yes")
   local add_agent=$(read-input "Add key to agent?" "yes")
   local remove_key=$(read-input "Remove public key?" "yes")

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
      local content="Host $hostalias"
	   content=+"\tHostname $server"
	   content=+"\tPort $port"
	   content=+"\tUser $user"
	   content=+"\tIdentityFile $key"
	   echo $content >> $config
   fi
   if [ "$add_agent" == "yes" ]; then
	   ssh-add $key
   fi
   if [ "$remove_key" == "yes" ]; then
      echo "Removing public key."
	   rm -f $key.pub
   fi
}

