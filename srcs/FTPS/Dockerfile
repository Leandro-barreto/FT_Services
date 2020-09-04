FROM alpine:latest

RUN apk update \
	&& apk upgrade \
	&& apk --update --no-cache add bash openssl vsftpd
RUN apk add --update --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

ENV FTP_USER=admin \
    FTP_PASS=admin \
    PASV_ENABLE=YES \
    PASV_ADDRESS="172.17.1.101" \
	PASV_ADDRESS_INTERFACE=eth0 \
	PASV_ADDR_RESOLVE=NO \
    PASV_MIN_PORT=21100 \
    PASV_MAX_PORT=21104

RUN mkdir -p /home/vsftpd/ && \
    chown -R ftp:ftp /home/vsftpd/

COPY srcs/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY srcs/setup.sh /usr/sbin/
COPY srcs/telegraf.conf /root/telegraf.conf
RUN chmod +x /usr/sbin/setup.sh

EXPOSE 20-22 21100-21104

ENTRYPOINT ["/usr/sbin/setup.sh"]
