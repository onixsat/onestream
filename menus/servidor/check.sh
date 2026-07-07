#!/usr/bin/env bash
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}Servidor - ${BOLD}${RED}Check${NORMAL}
EOM
 createMenu "menuCheck" "$ENV_VAR_MENU"
 printMenuStrs "menuCheck"
 addMenuItem "menuCheck" "Porta1" check1
 addMenuItem "menuCheck" "Porta2" check2
 addMenuItem "menuCheck" "Go back" loadMenu "menuServidor"
#loadMenu "menuConfig"
#pause

check1(){
	banner "Menu" "Servidor" "Check1"
	#source menus/servidor/porta.sh
	ipaddr=$(curl v4.ident.me)

	bash $thisFilePath/menus/scripts/porta.sh ${ipaddr} 20 80
	#read -n 1 -s -p "Press any key to continue 00"

	#	step "bash $thisFilePath/menus/scripts/porta.sh ${ipaddr} 20 80"
	#		try bash $thisFilePath/menus/scripts/porta.sh ${ipaddr} 20 80
	#	next
	#	read -n 1 -s -p "Press any key to continue 11"
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuCheck"
	pause
}