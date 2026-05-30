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
	

	step "Ver:"
		try bash ../scripts/porta.sh
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuCheck"
	pause
}
