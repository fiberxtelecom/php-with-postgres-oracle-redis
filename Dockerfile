FROM php:7-fpm

# Downloaded from Oracle: https://www.oracle.com/br/database/technologies/instant-client/linux-x86-64-downloads.html
# instantclient-basiclite-linux.x64-19.5.0.0.0dbru.zip
# instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip

ENV LD_LIBRARY_PATH /usr/local/instantclient/
ENV ORACLE_HOME /usr/local/instantclient/
ENV ORACLE_BASE /usr/local/instantclient/
ENV TNS_ADMIN /usr/local/instantclient/

COPY  instantclient-basic-linux.x64-19.5.0.0.0dbru.zip /tmp
COPY  instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip /tmp

RUN apt-get update && apt-get install -y zip unzip git libpq-dev libaio-dev  ${PHPIZE_DEPS} &&  unzip /tmp/instantclient-basic-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && unzip /tmp/instantclient-sdk-linux.x64-19.5.0.0.0dbru.zip -d /usr/local/ && ln -s /usr/local/instantclient_19_5 /usr/local/instantclient && pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient/ && ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1 && docker-php-ext-install pdo pdo_pgsql pgsql oci8 && docker-php-ext-enable redis && rm -rf /tmp/* /var/lib/apt/lists/* && apt-get remove -y zip unzip git ${PHPIZE_DEPS}

WORKDIR /code
EXPOSE 9000
CMD php-fpm

# check: php -m | grep 'oci8'