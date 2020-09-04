#! /bin/sh
SSH_USER=__SSH_USER__
SSH_PASS=__SSH_PASS__

ssh-keygen -A
adduser --disabled-password ${SSH_USER}
echo "${SSH_USER}:${SSH_PASS}" | chpasswd
/usr/sbin/sshd
# cp telegraf.conf /etc/telegraf.conf

export TELEGRAF_CONFIG_PATH=/root/telegraf.conf
telegraf & nginx -g "pid /tmp/nginx.pid; daemon off;"
