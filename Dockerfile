FROM php:7-fpm

# Downloaded from Oracle: https://www.oracle.com/br/database/technologies/instant-client/linux-x86-64-downloads.html
# instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip
# instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip

ENV LD_LIBRARY_PATH /usr/local/instantclient/
ENV ORACLE_HOME /usr/local/instantclient/
ENV ORACLE_BASE /usr/local/instantclient/
ENV TNS_ADMIN /usr/local/instantclient/
ENV PHP_INI_DIR=/usr/local/etc/php

COPY  instantclient-basic-linux.x64-19.5.0.0.0dbru.zip /tmp
COPY  instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip /tmp

RUN apt-get update && apt-get install -y zip unzip git libpq-dev libaio-dev libc-client-dev libkrb5-dev ${PHPIZE_DEPS} && rm -r /var/lib/apt/lists/* &&   unzip /tmp/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && unzip /tmp/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && ln -s /usr/local/instantclient_19_5 /usr/local/instantclient && pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient/ && docker-php-ext-configure imap --with-kerberos --with-imap-ssl &&  ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 && docker-php-ext-install pdo pdo_pgsql pgsql oci8 imap &&  docker-php-ext-enable redis && rm -rf /tmp/* /var/lib/apt/lists/* && apt-get remove -y zip ${PHPIZE_DEPS}

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 500M/g' "$PHP_INI_DIR/php.ini"
RUN sed -i 's/post_max_size = 2M/post_max_size = 500M/g' "$PHP_INI_DIR/php.ini"

WORKDIR /code
EXPOSE 9000
CMD php-fpm

# check: php -m | grep 'oci8'