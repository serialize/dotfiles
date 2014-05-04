#!/bin/bash
alias sskg="ssh-key-generate"
alias sska="ssh-key-add"

SSH_DIR=/home/$(whoami)/.ssh
SSH_CFG_FILE="$SSH_DIR"/config
SSH_KEY_PATTERN="$SSH_DIR"/.keys/id_

function ssh-key-add() {
	local host=$1 key=$SSH_KEY$1 known=$SSH_KNOW_HOSTS
	[[ -f $key ]] || exit 1
	[[ "$known" == "*$1*" ]] && { ssh-add $key  && $known+="$host " } 
	export SSH_KNOW_HOSTS=$known
}

function ssh-key-generate() {
	SSH_ALIAS=$(read-input "hostalias:")
	SSH_SERVER=$(read-input "hostname:")
	SSH_PORT=$(read-input "port:" "22")
	SSH_USER=$(read-input "user:")
	SSH_KEY=$SSH_KEY_PATTERN
	SSH_KEY+=$SSH_SETUP_ALIAS
	SSH_LOGIN="$SSH_USER@$SSH_SERVER"
	SSH_COMMENT="$(whoami)@$(hostname)_$(date -I)"
   
	ssh-keygen -t rsa -b 4096 -C $comment -f $key
	[[ $(read-input "Copy public key to remote host?" "yes") == "yes" ]] && ssh-copy-id -i $SSH_KEY -p $SSH_PORT $SSH_LOGIN
	[[ $(read-input "Write config?" "yes") == "yes" ] && { echo "Writing config file." && $(_ssh_write_config) } 
	[[ $(read-input "Add key to agent?" "yes") == "yes" ]] && ssh-add $SSH_KEY
	[[ $(read-input "Remove public key?" "yes") == "yes" ] && { echo "Removing public key." && rm -f $SSH_KEY.pub }
}

function _ssh_write_config() {
	local lines=()
	[[ -z "$SSH_ALIAS" ]] && lines+="Host $SSH_ALIAS" || echo "host parameter not given" && exit 1
	[[ -z "$SSH_SERVER" ]] && lines+="Hostname $SSH_SERVER"	
	[[ -z "$SSH_PORT" ]] && lines+="Port $SSH_PORT"	
	[[ -z "$SSH_USER" ]] && lines+="User $SSH_USER"	
	[[ -z "$SSH_KEY" ]] && lines+="IdentityFile $SSH_KEY"
	
	for line in lines; do 
		{ [[ "$line" == "Host *" ]] && echo $line || echo "\t$line" } >> $SSH_CFG_FILE
	done  	
}
