#!/usr/bin/env bash

set -e

web_user="apache"
NEXT_CLOUD_DIR="/var/www/html/nextcloud"
INSTALLER_URL="https://download.nextcloud.com/server/releases/nextcloud-16.0.3.zip"
ZIPPED_INSTALLER="nextcloud-16.0.3.zip"
DATA_DIR="/var/nextcloud/data"

sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime
sudo yum -y install epel-release yum-utils
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum -y install unzip

sudo yum-config-manager --disable remi-php54
sudo yum-config-manager --enable remi-php73
sudo yum -y install httpd php php-cli php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-intl php71-php-pecl-imagick php-ldap redis php-pecl-redis zip mariadb samba samba-client samba-common
sudo systemctl enable httpd smb.service

sudo curl $INSTALLER_URL --output $ZIPPED_INSTALLER
sudo unzip $ZIPPED_INSTALLER
sudo rm -f *.zip
sudo mv nextcloud/ /var/www/html/

sudo mkdir -p $DATA_DIR
sudo chown -R $web_user:$web_user $DATA_DIR
sudo chown -R $web_user:$web_user $NEXT_CLOUD_DIR

sudo sed -i 's/memory_limit = 128M/memory_limit = 513M/' /etc/php.ini
