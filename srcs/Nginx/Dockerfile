FROM alpine:latest
RUN apk add --no-cache nginx && \
    apk add --no-cache openssl && \
    apk add --no-cache openssh-server && \
    apk add --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

COPY ./srcs/ /root/

ADD srcs/telegraf.conf /etc/telegraf.conf
RUN chmod 755 root/setup.sh && \
    mv /root/nginx.conf /etc/nginx/nginx.conf && \
    mkdir -p /ssl/ && \
    openssl req -x509 -nodes -newkey rsa:2048 -keyout /ssl/cert.key -out /ssl/cert.crt -days 365 -subj '/CN=localhost'

RUN mkdir -p /var/www/html && \
    mv /root/index.html /var/www/html/

EXPOSE 80 443 1234

ENTRYPOINT ["/root/setup.sh"]
