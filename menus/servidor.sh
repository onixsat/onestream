#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Servidor${NORMAL}
EOM
createMenu "menuServidor" "$ENV_VAR_MENU"
addMenuItem "menuServidor" "Atualização" showInativo "Iniciar"
addMenuItem "menuServidor" "Reload" loadMenu "menuCheck"
addMenuItem "menuServidor" "Instalar" showInstalar2 "Instalar"
addMenuItem "menuServidor" "Configuração" showLoad "Load"
addMenuItem "menuServidor" "Segurança" loadMenu "menuConfig"

source "$thisFilePath/menus/global1.sh"
source menus/servidor/config.sh
source menus/servidor/check.sh

function showLoad(){
if @confirm 'Confirma que quer continuar?' ; then
	clear
	banner "Servidor" "$1" "load"
	source menus/servidor/load.sh	
else
echo "No"
fi
esperar "sleep 2" "Verificando..." " ${WHITE} Verificado! ${CINZA}Processos realizados em $GLOBAL_TIME segundos"
reload "return" "menuServidor"
pause
}



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
banner "Servidor" "$1" "Inátivo"
esperar "sleep 2" "Verificando..." " ${WHITE} Esta opção está inátiva"
reload "return" "menuServidor"
pause
}

