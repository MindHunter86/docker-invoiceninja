
# Invoice Ninja Dockerfiles
Customization of https://github.com/invoiceninja/dockerfiles

## Mounts
backend:
mkdir -p /var/www/app/public/logo /var/www/app/storage
mv /var/www/app/.env.example /var/www/app/.env
RUN mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

frontend:
/srv/invoiceninja/public

## Configuration:
https://github.com/invoiceninja/invoiceninja/blob/master/.env.example

## Pre start:
docker run --rm -it invoiceninja/invoiceninja php artisan key:generate --show

## First start:
php artisan config:cache
php artisan optimize
php artisan migrate:status
php artisan migrate --force
php artisan ninja:create-account $email $password

## Every start ? :
php artisan migrate:status
php artisan migrate --force

## Jobs:
scheduler - php artisan schedule:work
queue-worker - php artisan queue:work --sleep=3 --tries=1 --memory=256 --timeout=3600
