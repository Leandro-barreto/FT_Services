FROM alpine:latest

COPY ./srcs/ /tmp/
RUN apk update && \
    apk add lighttpd mysql-client && \
    apk add --update --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/ && \
    apk add php7 php7-openssl php7-cgi php7-xml php7-pdo php7-mcrypt php7-session php7-mysqli php7-zlib php7-json

EXPOSE 5050

ENTRYPOINT ["sh", "/tmp/setup.sh"]
