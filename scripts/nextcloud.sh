#!/usr/bin/env bash

set -e
sudo cp /usr/share/zoneinfo/Europe/London /etc/localtime

web_user="apache"
web_user_home="/usr/share/httpd"
occ_cmd="/var/www/html/nextcloud/occ"
sudo_cmd="/usr/bin/sudo"
NEXT_CLOUD_DIR="/var/www/html/nextcloud"
INSTALLER_URL="https://download.nextcloud.com/server/releases/nextcloud-16.0.3.zip"
ZIPPED_INSTALLER="nextcloud-16.0.3.zip"
DATA_DIR="/var/nextcloud/data"
INSTALLER_USER="installer_user"
echo "installing"
yum -y install epel-release yum-utils
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install unzip

yum-config-manager --disable remi-php54
yum-config-manager --enable remi-php73

yum -y install httpd php php-cli php-mysqlnd php-zip php-devel php-gd php-mcrypt php-mbstring php-curl php-xml php-pear php-bcmath php-json php-pdo php-pecl-apcu php-pecl-apcu-devel php-intl php71-php-pecl-imagick php-ldap redis php-pecl-redis zip mariadb samba samba-client samba-common
systemctl enable httpd smb.service

curl $INSTALLER_URL --output $ZIPPED_INSTALLER
unzip $ZIPPED_INSTALLER
rm -f *.zip

mv nextcloud/ /var/www/html/

mkdir -p $DATA_DIR
chown -R $web_user:$web_user $DATA_DIR
chown -R $web_user:$web_user $NEXT_CLOUD_DIR

temp_data_dir="/var/tmp/nextcloud/data"
mkdir -p $temp_data_dir
chown $web_user:$web_user $temp_data_dir
cd $NEXT_CLOUD_DIR
$sudo_cmd -u $web_user php $occ_cmd maintenance:install --database "sqlite" --admin-user "$INSTALLER_USER" --admin-pass "$INSTALLER_USER" --data-dir "/var/tmp/nextcloud/data"

$sudo_cmd -u $web_user php $occ_cmd app:enable twofactor_totp  #Enable 2f app
$sudo_cmd -u $web_user php $occ_cmd app:enable user_ldap         #Enable Ldap App

sed -i 's/memory_limit = 128M/memory_limit = 513M/' /etc/php.ini
