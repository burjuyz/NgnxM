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

#install nginx
apt-get install nginx -y
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/nginx.conf"
wget -O /etc/nginx/conf.d/xray.conf "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/xray.conf"
systemctl enable nginx && systemctl start nginx

#install cert
systemctl stop nginx
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
systemctl start nginx
wget -O /var/lib/marzban/xray_config.json "https://raw.githubusercontent.com/v1nch3r/MarzbanX/main/xray_config.json"

#さいごだ
apt autoremove -y && apt clean
cd /opt/marzban && docker compose down && docker compose up -d