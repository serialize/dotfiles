#!/bin/bash
PS1_COLOR_FORE_FORMAT="38;5;"
PS1_COLOR_BACK_FORMAT="48;5;"
PS1_COLOR_DEFAULT="1;32"
PS1_COLOR_RESET=" \e[0m"
PS1_COLOR_LOGIN=( 15 238 )
PS1_COLOR_PATH=( 15 241 )
PS1_COLOR_GIT=( 15 244 )
PS1_COLOR_GIT_OK=82
PS1_COLOR_GIT_CHG=1
PS1_SPACER="▶" #\u25B6" # ▶
PS1_LOGIN="\u@\h"
PS1_PATH="\w"

actual_colors=()


_str_sep() { echo -en "▶" }

_str_ws() { echo -en " " }

_str_nl() { echo -en "\n" }


_append() { [[ "$1" ]] && cache+="$1" }

_append_nl() { _append "$(_str_nl)" }

_append_ws() { _append "$(_str_ws)" }

_append_separator() { _append "$(_str_sep)" }

_append_ws_left() { [[ "$1" ]] && _append "$(_mod_ws_left $1)" }

_append_ws_right() { [[ "$1" ]] && _append "$(_mod_ws_right $1)" }

_append_ws_wrap() { [[ "$1" ]] && _append "$(_mod_ws_wrap $1)" }

_append_wrap() { [[ "$1" ]] && [[ "$2" ]] && [[ "$3" ]] && _append "$(_mod_wrap $@)" }

_append_unicode() { [[ "$1" ]] && [[ "$2" ]] && [[ "$3" ]] && _append "$(_mod_unicode $@)" }

_append_git_count() {
	[[ "$1" ]] || return 1
	local ok= chg=
	ok=PS1_COLOR_GIT_OK
	chg=PS1_COLOR_GIT_CHG
	[[ $1 == 0 ]] && _set_colors $ok || _set_colors $chg
	_append_ws_left $1 
}


_mod_ws_left() { [[ "$1" ]] && echo -en "$(_str_ws)$1" }

_mod_ws_right() { [[ "$1" ]] && echo -en "$1$(_str_ws)" }

_mod_ws_wrap() { [[ "$1" ]] && echo -en "$(_str_ws)$1$(_str_ws)" }

_mod_wrap() { [[ "$1" ]] && && [[ "$2" ]] && [[ "$3" ]] && echo -en "$2""$1""$3" }

_mod_unicode() { [[ "$1" ]] && [[ "$2" ]] && [[ "$3" ]] && echo -en "\x$1\x$2\x$3" }


function ps1_prompt() {
	PS1=""
	
	git-parse-current-dir
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# build blocks
	_build_login
	login_block=_flush_cache
	
	_build_path
	path_block=_flush_cache	
	
	_build_git
	git_block=_flush_cache
	
	_build_debug
	debug_block=flush_cache
	
	local litop= limid= libot=
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# build first line from blocks
	_build_line_prefix 1
	_append $login_block
	_append $path_block
	
	if [[ "$git_block" ]]; then
		_append $path_block
	fi
	litop=flush_cache
	
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# build debug line if exists  
	if [[ "$debug_block" ]]; then
		_append_nl
		_build_line_prefix 2
		_append	$debug_block		
	fi
	limid=flush_cache
				
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	# build debug line if exists  
	_append_nl
	_build_line_prefix 3
	_clear_colors
	_append_ws
	libot=flush_cache
		
	[[ "$litop" ]] && PS1+="$litop"
	[[ "$limid" ]] && PS1+="$limid"
	[[ "$libot" ]] && PS1+="$libot"
				
}

function ps1_prompt_old() {
	PS1_GIT="$(_ps1_format_git) "
	PS1+=$(echo -en "\xe2\x94\x8c")
	PS1+=$(echo -en "\xe2\x94\x80")
	
	PS1+=$(ps1_render_color ${PS1_COLOR_LOGIN[0]} ${PS1_COLOR_LOGIN[1]})
	PS1+=" $PS1_LOGIN " 
	PS1+=$(ps1_render_color ${PS1_COLOR_LOGIN[1]} ${PS1_COLOR_PATH[1]})
	PS1+="$PS1_SPACER"
	
	PS1+=$(ps1_render_color ${PS1_COLOR_PATH[0]} ${PS1_COLOR_PATH[1]})
	PS1+=" $PS1_PATH "
	PS1+=$(ps1_render_color ${PS1_COLOR_PATH[1]} ${PS1_COLOR_GIT[1]})
	PS1+="$PS1_SPACER"
		
	PS1+=$(ps1_render_color ${PS1_COLOR_GIT[0]} ${PS1_COLOR_GIT[1]})
	PS1+=" $PS1_GIT "
	PS1+="\033[0m "
	#PS1+=$(echo -en "\xe2\x94\x80")
	#PS1+=$(echo -en "\xe2\x95\xbc")
	PS1+="\n"

	PS1+=$(echo -en "\xe2\x94\x94")
	PS1+=$(echo -en "\xe2\x94\x80")
	PS1+=$(echo -en "\xe2\x95\xbc")
	PS1+=" "
}

_set_fg_color() {
	[[ "$1" ]] || return 1
	local fg= 
	if [[ "$1" != "${actual_colors[0]}" ]]; then
		fg="$1"
	fi
}

_check_color() {
	[[ "$1" ]] && [[ "$2" ]] || return 1
	[[ $1 != ${actual_colors[$2]} ]] || return 1
	return 0
}

_set_colors() {
	[[ "$1" ]] || return 1
	local fg= bg= color=

	[[ _check_color $1 0 ]] || fg="$1"
	[[ _check_color $2 1 ]] || bg="$2"
	
	#if [[ "$fg" ]] && [[ "$bg" ]];then
	if [[ "$fg" && "$bg" ]];then
		color="38;5;$fg;48;5;$bg"
		actual_colors[0]="$fg"
		actual_colors[1]="$bg"
	elif [[ "$fg" ]];then
		color="38;5;$fg"
		actual_colors[0]="$fg"
	elif [[ "$bg" ]];then
		color="48;5;$bg"
		actual_colors[1]="$bg"
	fi
	
	if [[ "$color"]];then
		_append_wrap $color "\033[" "m"	
	fi
}
_clear_colors() {
	actual_colors=()
	_append "\033[0m"	
}
_push_bg_color() {
	local fg= bg= 
	[[ ${actual_colors[1]} ]] && fg=${actual_colors[1]}
	[[ "$1" ]] && bg="$1"
	_set_color "$fg" "$bg"
}


_render() { 
	if [[ "$cache" ]];then 
		PS1+="$cache"
		cache= 
	fi
}

_flush_cache() {
	echo -en "$cache"
	cache=
	unset $cache
}

_build_line_prefix() {
	case "$1" in
		1) 	_append_unicode e2 94 8c
			_append_unicode e2 94 80
			#_append_ws
	    ;;
		2) 	_append_unicode e2 94 82
			_append_ws
			_append "[DEBUG]"
			_append_ws
	    	    ;;
		3) 	_append_unicode e2 94 94
			_append_unicode e2 94 80
			_append_unicode e2 95 bc
			_append_ws
	    ;;
	esac
}


_build_login() {
	_set_colors 15 238
	_append_ws_wrap "\u@\h"
}

_build_path() {
	_push_bg_color 244
	_append_separator
	_set_fg_color 15
	_append_ws_wrap "\w"
}

_build_git() {
	[[ "$GIT_CURRENT_BRANCH" ]] || return 1
	_push_bg_color 244
	_append_separator
	_set_fg_color 15
	_append_ws_wrap $GIT_CURRENT_BRANCH
	_append "-"
	_append_git_count $GIT_CURRENT_COUNT_MOD
	_append_git_count $GIT_CURRENT_COUNT_NEW
	_append_git_count $GIT_CURRENT_COUNT_DEL
	_set_fg_color 15
	_append_ws
}
PROMPT_COMMAND=ps1_prompt
