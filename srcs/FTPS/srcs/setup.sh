#!/bin/bash

openssl req -x509 -nodes -days 7300 -newkey rsa:2048 -subj "/C=BR/ST=br/L=Brasil/O=42 SP/CN=phippy" -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem
chmod 600 /etc/ssl/private/vsftpd.pem
export TELEGRAF_CONFIG_PATH=/root/telegraf.conf

# Add the FTP_USER, change his password and declare him as the owner of his home folder and all subfolders
addgroup -g 433 -S $FTP_USER
adduser -u 431 -D -G $FTP_USER -h /home/vsftpd/$FTP_USER -s /bin/false  $FTP_USER
echo "$FTP_USER:$FTP_PASS" | /usr/sbin/chpasswd
chown -R $FTP_USER:$FTP_USER /home/vsftpd/$FTP_USER
echo "Teste FTP" > /home/vsftpd/admin/file

# Update the vsftpd.conf according to env variables
sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_enable=.*/pasv_enable=$PASV_ENABLE/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_address=.*/pasv_address=$PASV_ADDRESS/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_addr_resolve=.*/pasv_addr_resolve=$PASV_ADDR_RESOLVE/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_max_port=.*/pasv_max_port=$PASV_MAX_PORT/" /etc/vsftpd/vsftpd.conf
sed -i "s/pasv_min_port=.*/pasv_min_port=$PASV_MIN_PORT/" /etc/vsftpd/vsftpd.conf

# Run the vsftpd server
telegraf & /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
