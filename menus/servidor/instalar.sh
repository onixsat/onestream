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
  sudo apt-get update
  sudo apt-get -y install git
  sudo apt-get -y install bind-utils
  sudo apt-get -y install telnet
  sudo apt-get -y install whois
  sudo apt-get -y install nc

#  https://sleeplessbeastie.eu/2023/10/30/how-to-install-packages-non-interactively-using-apt/
#!/bin/bash
function esperar2(){
}
log_info "Updating package lists and upgrading system..."
add "Atualizar" "sudo apt update -y" "1"
add "Atualizar" "sudo apt upgrade -y" "1"
read -n 1 -s -p "Press any key to continue 1"
clear

titulo "Instalar pacotes do sistema..."
log_info "Installing required packages..."
start_time2=$(date +%s%3N)

sudo apt install ufw net-tools nginx openssh-server certbot python3-certbot-nginx iptables-persistent php8.3-cli php8.3-fpm php8.3-mcrypt curl
sudo apt update

end_time2=$(date +%s%3N)
duration_ms2=$((end_time2 - start_time2))
echo -e "Execution1: $duration_ms2"
esperar2 "sleep 5" "Instalando..." " ${WHITE} Instalado!"
read -n 1 -s -p "Press any key to continue 2"
clear

log_info "Configuring UFW..."
ufw allow 22
ufw allow 80/tcp 
ufw allow 443/tcp 
ufw allow 21/tcp 
ufw allow 8080/tcp 
ufw allow 8443/tcp 
ufw allow 9000/tcp 
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

read -n 1 -s -p "Press any key to continue 3"
clear

titulo "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 9000 -j ACCEPT

esperar2 "sleep 5" "Configurando..." " ${WHITE} Configurado!"

read -n 1 -s -p "Press any key to continue 4"
clear
titulo "Instalar pacotes do sistema..."
if ! command -v nginx-ui &> /dev/null; then
    bash -c "$(curl -fsSL https://cloud.nginxui.com/install.sh)" @ install
else
    log_warn "Nginx UI already installed, skipping..."
fi
esperar2 "sleep 5" "Atualizando..." " ${WHITE} Atualizado!"

read -n 1 -s -p "Press any key to continue 5"
clear

titulo "Script complete!"
esperar2 "sleep 5" "..." " ${WHITE} OK!"

read -n 1 -s -p "Press any key to continue 6"
clear




	reload "return" "menuInstalar"
	pause
}
