#!/bin/sh
globais
source "$thisFilePath/menus/global1.sh"

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Nginx${NORMAL}
EOM
createMenu "menuNginx" "$ENV_VAR_MENU"
addMenuItem "menuNginx" "Installs Default" showInativo2 "Instalar apps default"
addMenuItem "menuNginx" "Restart" showInativo2 "Restart"
addMenuItem "menuNginx" "X Editor" showEditar "Editor"
addMenuItem "menuNginx" "Logs" showInativo2 "Logs"
addMenuItem "menuNginx" "Segurança" showInativo2 "Segurança"
addMenuItem "menuNginx" "Configuração" showInativo2 "Configuração"
addMenuItem "menuNginx" "Dominios" showInativo2 "Dominios"
addMenuItem "menuNginx" "Configurar" showInativo2 "Configurar"
addMenuItem "menuNginx" "Backups" showInativo2 "Backups"
addMenuItem "menuNginx" "X Restaurar" showSubmenu2



confirm_continue() {
    while true; do
        # -n prevents newline, -r prevents backslash escapes
        read -r -p "Press Y to continue, or any other key to exit: " answer
        
        # Convert to lowercase for case-insensitive comparison
        case "${answer,,}" in
            y)
                echo "Continuing..."
		sleep 2
                return 0
                ;;
            *)
                echo "Exiting..."
		sleep 2
                exit 1
                ;;
        esac
    done
}


function conf(){


sudo ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/
sed -i 's/#server_names_hash_bucket_size/server_names_hash_bucket_size/' /etc/nginx/nginx.conf
sudo nginx -t
sudo systemctl reload nginx

echo "Starting script..."

sudo chown -R www-data:www-data /var/log/nginx
sudo chmod 755 /var/log/nginx
sudo chown -R www-data:www-data /var/log/nginx
sudo chown -R www-data:www-data /var/log/nginx/*
sudo chmod 755 /var/log/nginx
sudo chmod 755 /var/log/nginx/*
ps -o user,group,comm -C nginx
sudo chown www-data:www-data /var/log/nginx/*.log
sudo chmod 644 /var/log/nginx/*.log

confirm_continue

echo "Script continues..."

if ! nginx -t >/tmp/nginx_test.log 2>&1; then
    echo "❌ Nginx configuration test failed!"
    cat /tmp/nginx_test.log
    exit 1
fi

# Step 2: Reload Nginx
if nginx -s reload 2>/tmp/nginx_reload_error.log; then
    echo "✅ Nginx reloaded successfully."
else
    echo "❌ Failed to reload Nginx!"
    cat /tmp/nginx_reload_error.log
    exit 1
fi


}
GITHUB="https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/editor/nginx/alterados/etc/nginx/"
getRand(){
    min="${1:-1}"   ## min is the first parameter, or 1 if no parameter is given
    max="${2:-100}" ## max is the second parameter, or 100 if no parameter is given
    rnd_count=$((RANDOM % ( $max - $min + 1 ) + $min )); ## get a random value using /dev/urandom
    echo "$rnd_count"
}
function cmd1(){ 
    rnd_count=$((RANDOM % ( 8089 - 8080 + 1 ) + 8080 )); ## get a random value using /dev/urandom
	ipaddr=$(curl v4.ident.me)
	sudo ufw allow ${rnd_count}/tcp
	php -S ${ipaddr}:${rnd_count} >/dev/null 2>&1 &
    if [ $? -eq 0 ]; then
		echo "Server (http://${ipaddr}:${rnd_count}) started"
		       sleep 10
       return 0
    else
        echo "failed"
        sleep 3
		exit 1
    fi
}
function showEditar(){
	banner "Nginx" "$1" "Editar arquivos"
	cd $thisFilePath/editor
	step "Ligar localhost:"
		try cmd1
	next	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"
	reload "return" "menuNginx"
	pause
}
function showSubmenu2(){
	source "$thisFilePath/config/submenus.sh"
	sub-menu "menuNginx"
	reload "return" "menuNginx"
	pause
}
function showInativo2(){
	banner "Nginx" "$1" "Inátivo"
	esperar "sleep 2" "Verificando..." " ${WHITE} Esta opção está inátiva"
	reload "return" "menuNginx"
	pause
}
function showNovo(){
	banner "Menu" "Nginx" "Atualizar"
	step "Backup arquivos /etc/nginx: /home"
	sudo zip -r -e /home/backup$RANDOM.zip /etc/nginx
	next

	step "Desbloquear arquivos:"
		try sudo chattr -i /etc/nginx/sites-available/lb.conf
		try sudo rm /etc/nginx/sites-available/lb.conf
		try sudo chattr -i /etc/nginx/sites-available/bo.conf
		try sudo rm /etc/nginx/sites-available/bo.conf
		try sudo chattr -i /etc/nginx/sites-enabled/default
		try sudo rm /etc/nginx/sites-enabled/default
		try sudo chattr -i /etc/nginx/nginx.conf
		try sudo rm /etc/nginx/nginx.conf
	next
	
	step "Salvar arquivos:"
		try sudo wget "${GITHUB}nginx.conf?raw=True" -O /etc/nginx/nginx.conf &> 1.log &
		try sudo wget "${GITHUB}sites-enabled/default?raw=True" -O /etc/nginx/sites-enabled/default &> 1.log &
		try sudo wget "${GITHUB}sites-available/lb.conf?raw=True" -O /etc/nginx/sites-available/lb.conf &> 1.log &
		try sudo wget "${GITHUB}sites-available/bo.conf?raw=True" -O /etc/nginx/sites-available/bo.conf &> 1.log &
	next

	step "Bloquear arquivos:"
  		try sudo chattr +i /etc/nginx/sites-available/lb.conf
		try sudo chattr +i /etc/nginx/sites-available/bo.conf
		try sudo chattr +i /etc/nginx/sites-enabled/default
		try sudo chattr +i /etc/nginx/nginx.conf
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuNginx"
	pause
	
}
function showOriginal(){
	banner "Menu" "Nginx" "Originais"
	
	step "Desbloquear arquivos:"
		try sudo chattr -i /etc/nginx/sites-available/lb.conf
		try sudo rm /etc/nginx/sites-available/lb.conf
		try sudo chattr -i /etc/nginx/sites-available/bo.conf
		try sudo rm /etc/nginx/sites-available/bo.conf
		try sudo chattr -i /etc/nginx/sites-enabled/default
		try sudo rm /etc/nginx/sites-enabled/default
		try sudo chattr -i /etc/nginx/nginx.conf
		try sudo rm /etc/nginx/nginx.conf
	next
	
	step "Salvar arquivos:"
		sudo unzip -d / backup31125.zip
		try sudo wget "${GITHUB}files/originais/lb.conf?raw=True" -O /etc/nginx/sites-available/lb.conf &> 1.log &
		try sudo wget "${GITHUB}files/originais/bo.conf?raw=True" -O /etc/nginx/sites-available/bo.conf &> 1.log &
	next
	
	step "Bloquear arquivos:"
  		try sudo chattr +i /etc/nginx/sites-available/lb.conf
		try sudo chattr +i /etc/nginx/sites-available/bo.conf
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuNginx"
	pause
}
