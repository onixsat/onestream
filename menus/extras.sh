#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Extras${NORMAL}
EOM
createMenu "menuExtras" "$ENV_VAR_MENU"
addMenuItem "menuExtras" "Procurar" showProcurar

function showProcurar(){
	banner "Extras" "Dominios" "Procurar"
  {
    titulo "Qual o dominio?"
    read -e -p "${MAGENTA}Procurar:${NORMAL} " -i "cms.panel-access.xyz" word
    echo -e "Procurou por $word"
	  source config/dns.sh ${word}
	  esperar "sleep 1" "${WHITE}Terminado... "
  } 2>&1 | tee dns_$(date '+%Y-%m-%d').log
  echo -e ""
	reload "return" "menuExtras"
	pause
}
