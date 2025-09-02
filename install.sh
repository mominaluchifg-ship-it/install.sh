#!/bin/bash
set -e

# ==============================
# Pterodactyl + Nebula Installer
# By mominaluchifg-ship-it
# ==============================

# --- Configurable Variables ---
export PANEL_DOMAIN="panel.asidcloud.com"
export WINGS_DOMAIN="play.asidmc.fun"
export ADMIN_EMAIL="mominaluchifg@gmail.com"
export ADMIN_USERNAME="admin"
export ADMIN_FIRST="Admin"
export ADMIN_LAST="User"
export ADMIN_PASSWORD="asidowner"

# --- System Update ---
apt update -y && apt upgrade -y

# --- Install Dependencies ---
apt install -y curl wget unzip tar

# --- Install Pterodactyl Panel ---
echo "⚡ Installing Pterodactyl Panel..."
# yahan apne pterodactyl panel installation steps daal do
# Example: curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
# tar -xzvf panel.tar.gz -C /var/www/pterodactyl

# --- Install Wings ---
echo "⚡ Installing Wings..."
# example command: curl -Lo wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
# chmod +x wings && mv wings /usr/local/bin/

# --- Apply Nebula Theme ---
echo "✨ Applying Nebula Theme..."
bash <(curl -s https://raw.githubusercontent.com/TheFonix/Pterodactyl-Themes/master/MasterThemes/Nebula/build.sh)

# --- Finish ---
echo ""
echo "✅ Installation Complete!"
echo "🌐 Panel: http://${PANEL_DOMAIN}"
echo "👤 Admin: ${ADMIN_USERNAME} / ${ADMIN_PASSWORD}"
echo "📧 Email: ${ADMIN_EMAIL}"
echo "💾 Database User: ptero / (check .env for password)"
echo "🪽 Wings running with IP: ${WINGS_DOMAIN}"
