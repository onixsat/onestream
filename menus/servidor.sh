#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Servidor${NORMAL}
EOM
createMenu "menuServidor" "$ENV_VAR_MENU"
addMenuItem "menuServidor" "Atualização" showInativo "Atualização"
addMenuItem "menuServidor" "X Reload" loadMenu "menuCheck"
addMenuItem "menuServidor" "X Instalar" showInstalar2 "Instalar"
addMenuItem "menuServidor" "Configuração" showInativo "Configuração"
addMenuItem "menuServidor" "Segurança" showInativo "Segurança"

source "$thisFilePath/menus/global1.sh"
source menus/servidor/check.sh

function showInstalar2(){
	banner "Servidor" "$1" "Instalar"
	if @confirm 'Confirma que quer instalar?' ; then
		source menus/servidor/instalar.sh
	else
		echo "No"
	fi
	esperar "sleep 2" "Verificando..." " ${WHITE} PPPPPPPPPPP"
	reload "return" "menuServidor"
	pause
}

function showInativo(){
	display_banner
	banner "Servidor" "$1" "Inátivo"
	esperar "sleep 2" "Verificando..." " ${WHITE} Esta opção está inátiva"
	reload "return" "menuServidor"
	pause
}

