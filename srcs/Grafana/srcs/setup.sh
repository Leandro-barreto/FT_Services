#!/bin/sh

export TELEGRAF_CONFIG_PATH="/tmp/telegraf.conf"
telegraf & /usr/sbin/grafana-server web
