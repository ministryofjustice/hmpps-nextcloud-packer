#!/usr/bin/env bash

#set -e

web_user="apache"
web_user_home="/usr/share/httpd"
occ_cmd="/var/www/html/nextcloud/occ"
sudo_cmd="/usr/bin/sudo"
NEXT_CLOUD_DIR="/var/www/html/nextcloud"
INSTALLER_URL="https://download.nextcloud.com/server/releases/nextcloud-16.0.3.zip"
ZIPPED_INSTALLER="nextcloud-16.0.3.zip"
DATA_DIR="/var/nextcloud/data"
INSTALLER_USER="installer_user"

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

temp_data_dir="/var/tmp/nextcloud/data"
sudo mkdir -p $temp_data_dir
sudo chown $web_user:$web_user $temp_data_dir
cd $NEXT_CLOUD_DIR
$sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "sqlite" --admin-user "$INSTALLER_USER" --admin-pass "$INSTALLER_USER" --data-dir "/var/tmp/nextcloud/data"

$sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp  #Enable 2f app
$sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap         #Enable Ldap App

sed -i 's/memory_limit = 128M/memory_limit = 513M/' /etc/php.ini
