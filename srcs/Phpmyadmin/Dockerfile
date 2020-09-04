FROM alpine:latest

COPY ./srcs/ /tmp1/
RUN apk update && \ 
    apk add lighttpd mysql-client && \
    apk add php7 php7-openssl php7-cgi php7-xml php7-pdo php7-mcrypt php7-session php7-mysqli php7-zlib php7-json php-iconv php-mbstring
ADD https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz /tmp1/phpmyadmin.tar.gz
RUN apk add --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/

EXPOSE 5000

ENTRYPOINT ["sh", "/tmp1/setup.sh"]
