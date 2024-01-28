#!/bin/bash

#domain
read -rp "Enter your domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#email
read -rp "Enter your Email: " email

#set Timezone GMT+3
timedatectl set-timezone Europe/Moscow

#preparation
apt-get update

#remove unused package
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install package
apt-get install sudo curl htop socat screen net-tools cron psmisc -y

#install marzban
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
marzban down
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/xray_config.json"
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/.env"
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/docker-compose.yml"

#install cert
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc

#install nginx
apt-get install nginx -y
systemctl stop nginx
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/xray.conf"
sed -i "s|domain.com|$domain|g" /etc/nginx/conf.d/xray.conf
rm -f /etc/nginx/sites-available/*
rm -f /etc/nginx/sites-enabled/*
systemctl start nginx

#install menu
wget -O /usr/bin/menu "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/menu/menu.sh" && chmod +x /usr/bin/menu
wget -O /usr/bin/xraylog "https://raw.githubusercontent.com/burjuyz/MarzbanNX/main/menu/xraylog.sh" && chmod +x /usr/bin/xraylog


#cleanup
apt autoremove -y && apt clean

#admincreate
cd /opt/marzban && docker compose down && docker compose up -d
marzban cli admin create --sudo
