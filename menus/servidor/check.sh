#!/usr/bin/env bash
read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}Servidor - ${BOLD}${RED}Check${NORMAL}
EOM
 createMenu "menuCheck" "$ENV_VAR_MENU"
 printMenuStrs "menuCheck"
 addMenuItem "menuCheck" "check1" check1
 addMenuItem "menuCheck" "Go back" loadMenu "menuServidor"
#loadMenu "menuConfig"
#pause
check1(){
read -r -d '' ENV_CONFIG << EOM
 Menu ${BLUE}Servidor - ${BOLD}${RED}Check1${NORMAL}
EOM

createMenu "menuCheck2" "$ENV_CONFIG"
printMenuStrs "menuCheck2"
source menus/scripts/porta.sh
addMenuItem "menuCheck2" "Go back" 'loadMenu "menuCheck"'

    loadMenu "menuCheck2"
    #reload "return" "menuConfig"
	pause
}