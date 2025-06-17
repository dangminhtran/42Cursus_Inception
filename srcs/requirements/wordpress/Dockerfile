FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	php-fpm \
	php-redis\
	php-mysql \
	php-cli \
	php-json \
	php-opcache \
	php-mbstring \
	php-xml \
	php-xmlrpc \
	php-curl \
	php-zip \
	php-bcmath \
	wget \
	unzip \
	mariadb-client \
	redis-tools \
	curl \
	&& apt clean

RUN mkdir -p /var/www /run/php

RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
	tar -xvf /tmp/wordpress.tar.gz -C /var/www/ && \
	chown -R www-data:www-data /var/www/wordpress

COPY ./conf/php.sh /usr/local/bin/php.sh
RUN chmod +x /usr/local/bin/php.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/php.sh"]
WORKDIR /var/www/wordpress
