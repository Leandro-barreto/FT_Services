FROM alpine:latest

RUN apk update && \
    apk add openrc --no-cache && \
    apk add --update --no-cache influxdb && \
    apk add --update --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY ./srcs/ /root/
COPY ["srcs/influxdb.conf", "/etc/influxdb.conf"]
COPY ["srcs/telegraf.conf", "/etc/telegraf.conf"]
RUN chmod 755 /root/setup.sh && \
    openrc && \
    touch /run/openrc/softlevel && \
    rc-update add telegraf

EXPOSE 8086 8088

ENTRYPOINT /etc/init.d/telegraf start; influxd -config /etc/influxdb.conf
