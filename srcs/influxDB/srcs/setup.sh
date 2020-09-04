#!/bin/sh

# telegraf & 
#influxd -config /etc/influxdb.conf

export TELEGRAF_CONFIG_PATH=/root/telegraf.conf
telegraf --config /root/telegraf.conf&

