FROM php:7.4.3-fpm-alpine3.11

# Downloaded from Oracle: https://www.oracle.com/br/database/technologies/instant-client/linux-x86-64-downloads.html
# instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip
# instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip

COPY  instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip /tmp
COPY  instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip /tmp

RUN apk update && apk add zip unzip git postgresql-dev libaio pcre-dev ${PHPIZE_DEPS} && unzip /tmp/instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && unzip /tmp/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && ln -s /usr/local/instantclient_19_5 /usr/local/instantclient && pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && export LD_LIBRARY_PATH=/usr/local/instantclient && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient && export ORACLE_HOME=instantclient,/usr/local/instantclient && docker-php-ext-install pdo pdo_pgsql pgsql && docker-php-ext-enable redis && rm -rf /usr/local/*.zip /tmp/*.zip /var/lib/apt/lists/* && apk del pcre-dev ${PHPIZE_DEPS}

EXPOSE 9000

CMD php-fpm
 
# docker build --label v2 . 
