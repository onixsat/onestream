#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}Servidor - ${BOLD}${RED}Instalar${NORMAL}
EOM
createMenu "menuInstalar" "$ENV_VAR_MENU"
addMenuItem "menuInstalar" "Instalar" showInstalar
addMenuItem "menuInstalar" "Go back" loadMenu "menuServidor"

function showInstalar(){
	banner "Menu" "Servidor" "Instalar"

titulo "Instalar pacotes do sistema..."
log_info "Installing required packages..."
start_time2=$(date +%s%3N)

sleep 5
end_time2=$(date +%s%3N)
duration_ms2=$((end_time2 - start_time2))
echo -e "Execution1: $duration_ms2"
esperar2 "sleep 5" "Instalando..." " ${WHITE} Instalado!"
titulo "Script complete!"
esperar2 "sleep 5" "..." " ${WHITE} OK!"

read -n 1 -s -p "Press any key to continue 6"
clear




	reload "return" "menuInstalar"
	pause
}
