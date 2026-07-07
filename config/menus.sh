#!/bin/bash
display_banner() {
   # clear
    echo -e "${GREEN}"
    cat << "EOF" 

  _____  _______  _____   ______  _____ 
 |     | |______ |_____] |_____/ |     |
 |_____| ______| |       |    \_ |_____|
                                        
                    Developer: OnixSat

EOF
    echo -e "${NC}${YELLOW}* GitHub: https://github.com/onixsat${NC}\n"
}
display_banner


HEADER_MSG="${CYAN}OS Gestor${NORMAL}"

read -r -d '' ENV_VAR_MENU << EOM
${RED}Main Menu${NORMAL}
EOM
createMenu "mainMenu" "$ENV_VAR_MENU"
addMenuItem "mainMenu" "Servidor" loadMenu "menuServidor"
addMenuItem "mainMenu" "Nginx" loadMenu "menuNginx"
addMenuItem "mainMenu" "Extras" loadMenu "menuExtras"
addMenuItem "mainMenu" "Quit" l8r

source menus/servidor.sh
source menus/nginx.sh
source menus/extras.sh
