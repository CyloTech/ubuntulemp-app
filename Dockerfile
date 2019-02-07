FROM ubuntu:18.04

ENV HOME=/home/appbox \
    DEBIAN_FRONTEND=noninteractive \
    MYSQL_ROOT_PASSWORD=mysqlr00t \
    START_SUPERVISOR=true

RUN apt update
RUN apt install -y wget \
                   curl \
                   git \
                   nginx \
                   php-fpm \
                   supervisor \
                   cron \
                   mysql-server \
                   php-mysql \
                   php-curl

RUN mkdir -p /run/php

RUN adduser --system --disabled-password --home ${HOME} --shell /sbin/nologin --group --uid 1000 appbox

ADD /scripts /scripts
RUN chmod -R +x /scripts

ADD /sources /sources
EXPOSE 80 3306

RUN apt autoremove -y && apt clean
RUN rm -rf /var/lib/apt/lists/*

CMD [ "/scripts/lemp.sh" ]