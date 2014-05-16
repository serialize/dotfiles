#!/bin/bash
PS_COLOR_FG=0
PS_COLOR_BG=0

_encode_color() { 
   echo -en "\[\e[$1m\]"
}
_color_reset() {
	echo -en "\[\e[0m\]"
}
_color_fg() {
   echo -en "\[\e[38;5;$1m\]"
}
_color_bg() {
   echo -en "\[\e[48;5;$1m\]"
}
_color_fg_bg() {
   echo -en "\[\e[38;5;$1;48;5;$2m\]"
}
_unicode_u() {
   echo -en "\[\u$1\]"
}
_unicode_x() {
   echo -en "\[\x$1\x$2\x$3\]"
}
_color() {
   if [[ $1==0 ]];then
      echo -en "$(_color_reset)"
   elif [[ $1 > 0 ]] && [[ $2 > 0 ]];then
      echo -en "$(_color_fg_bg '$1' '$2')"
   elif [[ "$1" ]];then
      echo -en "$(_color_fg '$1')"
   fi
}
_prefix() {
   echo -en "$(_color_reset)"
   case "$1" in
   "top")
      echo -en "┌" #$(_unicode_u 257E)"
	   #echo -en "$(_unicode_x e2 94 8c)"
	   #echo -en "$(_unicode_x e2 94 80)"
	   ;;
   "center")  
      echo -en "$(_unicode_x e2 94 82)"
	   echo -en " "
	   ;;
   "bottom")  
      #echo -en "$(_unicode_x e2 94 94)"
      #echo -en "$(_unicode_x e2 94 80)"
      #echo -en "$(_unicode_x e2 95 bc)"
      #echo -en "$(_unicode_u 2579)"
      echo -en "└╼"
	   ;;
   esac
   #echo -en " "
}
_separator() {
   echo -en "$(_color_fg_bg '$1' '$2')"
   echo -en "\[\u25b6\]"
   [[ "$3" ]] && echo -en "$(_color_fg '$3')"
}

render_color() {
   local fg=-1 bg=-1 
   [[ "$1" ]] && [[ "$1" != "$PS_COLOR_FG" ]] && fg=$1
   [[ "$2" ]] && [[ "$2" != "$PS_COLOR_BG" ]] && bg=$2
   
   [[ $fg < 0 && $bg < 0 ]] && return 0 
   
   [[ $fg == 0 || $fg > 0 ]] && export PS_COLOR_FG=$fg
   [[ $bg == 0 || $bg > 0 ]] && export PS_COLOR_BG=$bg
      
   [[ $fg == 0 || $bg == 0 ]] && echo -en "\[\e[0m\]"
   
   local color=
   [[ $fg > 0 && $bg > 0 ]] && color="38;5;$fg;48;5;$bg"
   [[ $fg > 0 ]] && [[ $bg == 0 || $bg < 0 ]] && color="38;5;$fg" 
   [[ $bg > 0 ]] && [[ $fg == 0 || $fg < 0 ]] && color="48;5;$bg" 
            
   if [[ "$color" ]];then
      echo -en "$(printf '\[\e[%sm\]' $color)"
   fi
}

render_content() {
    local content=
    content="$(render_color $2 $3)"
    [[ "$1" ]] && content+="$1"
    echo -en "$content"
}

render_prompt_1() {
   
   echo -en "$(_prefix 'top')"

   echo -en "$(_color_fg_bg '15' '238') "
   echo -en "\u@\h "
   echo -en "$(_color_fg_bg '238' '241')"
   echo -en "\[\u25b6\]"
   echo -en "$(_color_fg '15') "
   echo -en "\w "
   
   $(git-parse-current-dir)
   if [[ "$GIT_CURRENT_BRANCH" ]]; then
	   echo -en "$(_color_fg_bg '241' '244')"
	   echo -en "\u25b6"
	   echo -en "$(_color_fg '15') "
      echo -en "$GIT_CURRENT_BRANCH "
      echo -en "\u25b9 "
      echo -en "$GIT_CURRENT_COUNT_MOD "
      echo -en "$GIT_CURRENT_COUNT_NEW "
	   echo -en "$GIT_CURRENT_COUNT_DEL "
   fi
   echo -en "\[\e[0m\]"
   echo -en "\n"
                     
   echo -en "$(_prefix 'bottom') "
}

render_prompt_2_left() {
   echo -en "$(render_content '\[\u2576\]' $1 $2)"
   #echo -en "$(render_content '\u25c0' $1 $2)"
}
render_prompt_2_right() {
   echo -en "$(render_content '\[\u2574\]' $1 $2)"
   #echo -en "$(render_content '\u25b6' $1 $2)"
}
render_prompt_2_content() {
   echo -en "$(render_prompt_2_right 46 $3) "
   echo -en "$(render_content $1 $2 $3) "
   echo -en "$(render_prompt_2_left 46 $3)"
}
render_prompt_2_counts() {
   if [[ $1 > 0 ]];then
      echo -en "$(render_content $1 197 244)"
   else
      echo -en "$(render_content $1 221 244)"
   fi
}
render_prompt_spacer() {
   echo -en "$(_color_reset)"
   echo -en "$(_unicode_x e2 94 80)"
}

render_prompt_2() {
   echo -en "$(_prefix 'top')"
   
   echo -en "$(render_prompt_spacer)"
   echo -en "$(render_prompt_2_content '\u@\h' 15 238)"

   #echo -en "$(render_prompt_spacer)"
   echo -en "$(render_prompt_2_content '\w' 75 241)"
    
   echo -en "$(git-parse-current-dir)"     
   if [[ "$GIT_CURRENT_BRANCH" ]]; then
      local git=""
      #echo -en "$(render_prompt_spacer)"
      echo -en "$(render_prompt_2_right 46 244)"
      echo -en " $(render_content $GIT_CURRENT_BRANCH 221 244)"
      echo -en " $(render_content '\[\u2964\]' 221 244)"
      echo -en " $(render_prompt_2_counts $GIT_CURRENT_COUNT_MOD)"
      echo -en " $(render_prompt_2_counts $GIT_CURRENT_COUNT_NEW)"
      echo -en " $(render_prompt_2_counts $GIT_CURRENT_COUNT_DEL)"
      echo -en " $(render_prompt_2_left 46 244)"
   fi
   echo -en "$(render_prompt_spacer)"
   echo -e "$(_unicode_u 257C)"
   #echo -en "\n" 
   echo -en "$(_prefix 'bottom') " #\[\007\]"
}

render_prompt_old_1() {

#-----------------------------------
#  colors
#-----------------------------------
	red='\e[0;31m'
	RED='\e[1;31m'
	blue='\e[0;34m'
	BLUE='\e[1;34m'
	cyan='\e[0;36m'
	CYAN='\e[1;36m'
	NC='\e[0m'      # no color
	black='\e[0;30m'
	BLACK='\e[1;30m'
	green='\e[0;32m'
	GREEN='\e[1;32m'
	yellow='\e[0;33m'
	YELLOW='\e[1;33m'
	magenta='\e[0;35m'
	MAGENTA='\e[1;35m'
   #white='\e[0;37m'
	white='\e[0;37m'
	WHITE='\e[1;37m'
   #-----------------------------------
   #  symbols
   #-----------------------------------
	SYM_1='\xe2\x94\x8c' # ┌
	SYM_2='\xe2\x94\x80' # ─
	SYM_3='\xe2\x94\x94' # └
	SYM_4='\xe2\x8a\xa2' # ⊢
	SYM_5='\xe2\x8a\xa3' # ⊣
	SYM_7='\xe2\x95\xbc' # ╼
	SYM_8='\xe2\x8a\x8f' # ⊏
	SYM_9='\xe2\x8a\x90' # ⊐
	SYM_10='\xe2\x8a\x82' # ⊂
	SYM_11='\xe2\x8a\x83' # ⊃
	SYM_12='\xe2\x94\x9c' # ├
	SYM_13='\xe2\x94\xa4' # ┤
	SYM_14='\xe2\x94\x82' # │
   
   echo -e $SYM_1$SYM_2
   echo -en "$white\u@\h$NC"
   echo -en "$blue\w$NC"
   echo -en $SYM_3

   local gitbranch="$(git_get_branch_name)"
   if [ "$gitbranch" ]; then
      local gitcounts="$(git_get_count_mod)"
      gitcounts+="$(git_get_count_new)"
      gitcounts+="$(git_get_count_del)"
      echo -en $SYM_2$SYM_2[
      echo -en "$yellow$gitbranch$NC"
      echo -en "-"
      echo -en "$yellow$gitcounts$NC"
      echo -en ]$SYM_2
   else
      echo -en $SYM_2$SYM_2$SYM_2
   fi   
      
   echo -en $SYM_7"\x20"
}
