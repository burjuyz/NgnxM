#!/bin/bash

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#email
read -rp "Masukkan Email anda: " email

#set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta

#preparation
apt-get update

#remove unused package
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install package
apt-get install sudo curl htop socat screen net-tools cron neofetch -y

#install speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install marzban
sudo bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
marzban down
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/xray_config.json"
wget -O /opt/marzban/.env "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/.env"
wget -O /opt/marzban/docker-compose.yml "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/docker-compose.yml"

#install cert
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc

#install nginx
apt-get install nginx -y
systemctl stop nginx
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/xray.conf"
sed -i "s|domain.com|$domain|g" /etc/nginx/conf.d/xray.conf
rm -f /etc/nginx/sites-available/*
rm -f /etc/nginx/sites-enabled/*
systemctl start nginx

#install menu
wget -O /usr/bin/menu "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/menu/menu.sh" && chmod +x /usr/bin/menu
wget -O /usr/bin/xraylog "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/menu/xraylog.sh" && chmod +x /usr/bin/xraylog

#さいごだ
apt autoremove -y && apt clean
cd /opt/marzban && docker compose down && docker compose up -d
marzban cli admin create --sudo