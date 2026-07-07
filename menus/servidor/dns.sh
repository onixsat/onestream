#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}Servidor - ${BOLD}${RED}DNS${NORMAL}
EOM
createMenu "menuDns" "$ENV_VAR_MENU"
addMenuItem "menuDns" "Instalar" showInstalar
addMenuItem "menuDns" "Go back" loadMenu "menuServidor"

function showInstalar(){
	banner "Menu" "Servidor" "DNS"
  sudo apt-get update
  sudo apt-get -y install git
  sudo apt-get -y install bind-utils
  sudo apt-get -y install telnet
  sudo apt-get -y install whois
  sudo apt-get -y install nc

  echo "alias dg='bash config/dns.sh'" >> ~/.bashrc
  source ~/.bashrc

	reload "return" "menuDns"
	pause
}
