#!/bin/bash
# ======================================
# 🚀 Auto Installer - Pterodactyl + Nebula + Wings
# By mominaluchifg-ship-it - 9/2/2025
# ======================================

# ====== CONFIG ======
PANEL_DOMAIN="${PANEL_DOMAIN:-http://${panel.asidcloud.com}"
ADMIN_EMAIL="${ADMIN_EMAIL:-mominaluchifg@gmail.com}"
ADMIN_USERNAME="${ADMIN_USERNAME:-admin}"
ADMIN_FIRST="${ADMIN_FIRST:-admin}"
ADMIN_LAST="${ADMIN_LAST:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin12}"
SERVER_IP="${SERVER_IP:-play.asidmc.com}"

GREEN="\033[0;32m"
NC="\033[0m"

echo -e "${GREEN}🚀 Starting Full Installation...${NC}"

# ======================================
# Step 1: Dependencies
# ======================================
apt update -y
apt install -y software-properties-common curl apt-transport-https ca-certificates gnupg lsb-release

add-apt-repository -y ppa:ondrej/php
apt update -y
apt install -y php8.1 php8.1-{cli,gd,sqlite3,mysql,mbstring,bcmath,xml,curl,zip} mariadb-server nginx redis-server git unzip composer nodejs npm ufw

# ======================================
# Step 2: Database
# ======================================
DB_PASS=$(openssl rand -base64 16)
mysql -u root <<MYSQL_SCRIPT
CREATE USER 'ptero'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
CREATE DATABASE panel;
GRANT ALL PRIVILEGES ON panel.* TO 'ptero'@'127.0.0.1' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT

# ======================================
# Step 3: Panel
# ======================================
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache
cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate --force
php artisan migrate --seed --force

php artisan p:user:make \
  --email="${mominaluchifg@gmail.com}" \
  --username="${admin}" \
  --name-first="${admin}" \
  --name-last="${admin}" \
  --password="${admin12}" \
  --admin=1

# ======================================
# Step 4: Nginx
# ======================================
cat > /etc/nginx/sites-available/pterodactyl.conf <<EOL
server {
    listen 80;
    server_name ${PANEL_DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOL
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
systemctl restart nginx

# ======================================
# Step 5: Nebula Theme
# ======================================
echo -e "${GREEN}🌌 Installing Nebula Theme...${NC}"
curl -s https://raw.githubusercontent.com/mominaluchifg-ship-it/nebula-theme/main/nebula.sh | bash

# ======================================
# Step 6: Wings (Daemon)
# ======================================
echo -e "${GREEN}🪽 Installing Wings Daemon...${NC}"

mkdir -p /etc/pterodactyl
cd /etc/pterodactyl
curl -Lo wings.tar.gz https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64
mv wings_linux_amd64 wings
chmod +x wings

cat > /etc/systemd/system/wings.service <<EOL
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings.pid
ExecStart=/etc/pterodactyl/wings
Restart=on-failure
StartLimitInterval=600

[Install]
WantedBy=multi-user.target
EOL

systemctl enable wings
systemctl start wings

# ======================================
# Step 7: Networking + Port Forwarding
# ======================================
echo -e "${GREEN}🌐 Setting up networking...${NC}"

# Allow game ports
ufw allow 8080:65535/tcp
ufw allow 8080:65535/udp
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Force Wings to use custom IP
cat > /etc/pterodactyl/config.yml <<EOL
debug: false
uuid: auto
token: auto
api:
  host: 0.0.0.0
  port: 8080
system:
  root_directory: /var/lib/pterodactyl/volumes
  log_directory: /var/log/pterodactyl
  data: /var/lib/pterodactyl
  sftp:
    bind_port: 2022
  allowed_ips: [ASIDMC.fun]
docker:
  network:
    interface: ${play.ASIDMC.fun}
EOL

systemctl restart wings

# ======================================
# Done
# ======================================
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo "🌐 Panel: http://${panel.asidcloud.com}"
echo "👤 Admin: ${mominaluchifg@gmail.com} / ${admin12}"
echo "💾 Database User: ptero / ${DB_PASS}"
echo "🪽 Wings running with IP: ${play.asidmc.fun}"
