FROM php:8.2-fpm

# Variáveis de ambiente
ENV PHP_INI_DIR=/usr/local/etc/php \
    TNS_ADMIN=/usr/local/instantclient/ \
    ORACLE_BASE=/usr/local/instantclient/ \
    ORACLE_HOME=/usr/local/instantclient/ \
    LD_LIBRARY_PATH=/usr/local/instantclient/ \
    PHPIZE_DEPS="autoconf dpkg-dev file g++ gcc libc-dev make pkg-config re2c"

# Adiciona arquivos necessários
COPY instantclient-basic-linux.x64-19.20.0.0.0dbru.zip /tmp/
COPY instantclient-sdk-linux.x64-19.20.0.0.0dbru.zip /tmp/
# Instalação de dependências e extensões PHP
RUN apt-get clean  &&  \
    apt-get update -y  &&  \
    apt-get upgrade -y  &&  \
    apt-get install -y libxml2-dev zip unzip git libpng-dev libpq-dev libzip-dev libaio-dev libc-client-dev libkrb5-dev zlib1g-dev libmemcached-dev ${PHPIZE_DEPS}  &&  \
    rm -r /var/lib/apt/lists/*  && \
    unzip /tmp/instantclient-basic-linux.x64-19.20.0.0.0dbru.zip -d /usr/local/  &&  \
    unzip /tmp/instantclient-sdk-linux.x64-19.20.0.0.0dbru.zip -d /usr/local/  && \
    ln -s /usr/local/instantclient_19_20 /usr/local/instantclient  &&  \
    pecl install -o -f redis  && \
    pecl install -o -f memcached  && \
    rm -rf /tmp/pear  && \
    docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql  && \
    docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient/  && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl  && \
    docker-php-ext-configure opcache && \
    ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1

RUN docker-php-ext-install calendar xml soap pdo pdo_pgsql pgsql oci8 imap gd zip pdo_mysql opcache && \
    docker-php-ext-install gd zip  && \
    docker-php-ext-enable redis  && \
    docker-php-ext-enable memcached  && \
    docker-php-ext-enable pdo_mysql  && \
    rm -rf /tmp/* /var/lib/apt/lists/*  && \
    apt-get remove -y ${PHPIZE_DEPS}  && \
    docker-php-source delete  && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"  && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2G/g' "$PHP_INI_DIR/php.ini"  && \
    sed -i 's/post_max_size = 8M/post_max_size = 2G/g' "$PHP_INI_DIR/php.ini"  && \
    sed -i 's/memory_limit = 128M/memory_limit = 1000M/g' "$PHP_INI_DIR/php.ini" && \
    echo "opcache.enable=1" >>/usr/local/etc/php/php.ini && \
    echo "opcache.enable_cli=1" >>/usr/local/etc/php/php.ini && \
    echo "opcache.jit_buffer_size=500M" >>/usr/local/etc/php/php.ini && \
    echo "opcache.jit=1255" >>/usr/local/etc/php/php.ini

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        autoconf \
        g++ \
        make \
        pkg-config \
        supervisor \
        nginx

# Instala as extensões PHP necessárias
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install intl

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install exif

RUN docker-php-ext-enable bcmath
RUN docker-php-ext-enable exif

COPY nginx.conf /etc/nginx/nginx.conf

# Define diretório de trabalho
WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html

# Expõe a porta 9000
EXPOSE 80

# Comando padrão
CMD service nginx start && php-fpm