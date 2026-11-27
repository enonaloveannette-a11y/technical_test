FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx

RUN docker-php-ext-install pdo_mysql

COPY index.php /var/www/html/
COPY static/ /var/www/html/static/
COPY nginx.conf /etc/nginx/http.d/default.conf
COPY src/ /var/www/html/src/

RUN mkdir -p /run/nginx
COPY start.sh /start.sh
RUN chmod +x /start.sh
EXPOSE 8080
CMD ["/start.sh"]
