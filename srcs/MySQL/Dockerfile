FROM alpine:latest
RUN mkdir -p /run/mysqld && \
    mkdir -p /tmp
RUN apk add --update --no-cache mysql mysql-client && \
    apk add --update --no-cache telegraf \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing/
COPY srcs/mysql.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY srcs/ /tmp/
RUN chmod 755 /tmp/setup.sh
EXPOSE 3306 33060

ENTRYPOINT ["/tmp/setup.sh"]
