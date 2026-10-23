#!/usr/bin/env bash
# Setup idempotent du site de telechargement sur le VPS (lance par GitHub Actions).
# Usage : bash setup-site.sh <dossier contenant site/ et deploy/>
set -euo pipefail

SRC="${1:-$HOME/memedrop-site-upload}"
DOMAIN="memedrop.57-131-40-94.sslip.io"
WEBROOT="/var/www/memedrop"
VHOST="/etc/nginx/sites-available/memedrop-site"

sudo mkdir -p "$WEBROOT/download"
sudo chown -R "$USER:$USER" "$WEBROOT"

# Fichiers statiques (on ne touche pas a download/ ni a latest.json, geres par la release)
find "$WEBROOT" -mindepth 1 -maxdepth 1 ! -name download ! -name latest.json -exec rm -rf {} +
cp -r "$SRC/site/." "$WEBROOT/"

# Vhost : installe seulement la premiere fois, ensuite certbot l'a modifie
if [ ! -f "$VHOST" ]; then
  sudo cp "$SRC/deploy/nginx-memedrop.conf" "$VHOST"
  sudo ln -sf "$VHOST" /etc/nginx/sites-enabled/memedrop-site
  sudo nginx -t
  sudo systemctl reload nginx
fi

# Certificat HTTPS (Let's Encrypt) si absent
if ! sudo test -d "/etc/letsencrypt/live/$DOMAIN"; then
  sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos \
    --register-unsafely-without-email --redirect
fi

echo "OK -> https://$DOMAIN"
