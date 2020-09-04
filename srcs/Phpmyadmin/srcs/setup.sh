#!/bin/sh

mkdir -p /run/lighttpd
touch /run/lighttpd/php-fastcgi.socket
chown -R lighttpd:lighttpd /run/lighttpd
mv /tmp1/lighttpd.conf /etc/lighttpd/lighttpd.conf
mv /tmp1/mod_fastcgi.conf /etc/lighttpd/mod_fastcgi.conf

mkdir -p /var/www/phpmyadmin
tar -zxvf /tmp1/phpmyadmin.tar.gz -C /var/www/phpmyadmin --strip 1
mv /tmp1/config.inc.php /var/www/phpmyadmin/config.inc.php
sed -i 's|;session.save_path = "/tmp"|session.save_path = "/tmp"|g' /etc/php7/php.ini
chmod -R 755 /var/www/
chown lighttpd -R /var/www/
mysql -h 172.17.1.100 -uroot -padmin < tmp1/mysql.sql

export TELEGRAF_CONFIG_PATH=/tmp1/telegraf.conf
telegraf & /usr/sbin/lighttpd -D -f /etc/lighttpd/lighttpd.conf

