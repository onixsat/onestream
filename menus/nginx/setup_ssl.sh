#!/bin/bash
 
# Usage: ./setup_ssl.sh <domain> <email>
 
# Input parameters
DOMAIN=$1
EMAIL=$2
 
# Check if domain and email are provided
if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: $0 <domain> <email>"
    exit 1
fi
 
# Install Certbot and necessary dependencies
echo "Installing Certbot and necessary dependencies..."
sudo apt update
sudo apt install certbot python3-certbot-nginx -y
 
# Obtain an SSL certificate and configure Nginx
echo "Obtaining SSL certificate for $DOMAIN..."
sudo certbot --nginx --non-interactive --agree-tos --redirect -d $DOMAIN -m $EMAIL
 
# Reload Nginx to apply SSL
echo "Reloading Nginx to apply SSL certificate..."
sudo systemctl reload nginx
 
echo "SSL setup for $DOMAIN is complete."