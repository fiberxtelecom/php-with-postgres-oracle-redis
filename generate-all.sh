docker pull php:8.2-fpm
docker pull php:8.1-fpm
docker pull php:7.4-fpm

docker build -f ./Dockerfile-7.4 -t dopanel/php-postgres-oracle-redis:7.4 .
docker build -f ./Dockerfile-8.1 -t dopanel/php-postgres-oracle-redis:8.1 .
docker build -f ./Dockerfile-8.2 -t dopanel/php-postgres-oracle-redis:8.2 .
docker build -f ./Dockerfile-8.2 -t dopanel/php-postgres-oracle-redis .
