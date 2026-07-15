#!/bin/bash
 
# Usage: ./setup_nginx.sh <domain> <port>
 
# Input parameters
DOMAIN=$1
PORT=$2
 
# Check if domain and port are provided
if [ -z "$DOMAIN" ] || [ -z "$PORT" ]; then
    echo "Usage: $0 <domain> <port>"
    exit 1
fi
 
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_CONF_LINK="/etc/nginx/sites-enabled/$DOMAIN"
 
# Update and install Nginx
echo "Updating system and installing Nginx..."
sudo apt update
sudo apt install nginx -y
 
# Create Nginx server block dynamically based on domain and port
echo "Configuring Nginx for $DOMAIN..."
if [ ! -f "$NGINX_CONF" ]; then
    sudo bash -c "cat > $NGINX_CONF" <<EOF
server {
    listen 80;
    server_name $DOMAIN;
 
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
 
    location /api {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
else
    echo "Nginx config for $DOMAIN already exists."
fi
 
# Enable Nginx config
if [ ! -f "$NGINX_CONF_LINK" ]; then
    sudo ln -s $NGINX_CONF $NGINX_CONF_LINK
    echo "Nginx configuration for $DOMAIN enabled."
else
    echo "Nginx configuration already enabled."
fi
 
# Restart Nginx
echo "Restarting Nginx..."
sudo systemctl restart nginx
 
echo "Nginx setup for $DOMAIN on port $PORT is complete."