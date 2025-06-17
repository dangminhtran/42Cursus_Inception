FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	php-cli \
	php-mbstring \
	php-xml \
	php-curl \
	php-zip \
	php-mysql \
	php-gd \
	wget \
	unzip \
	tini \
	&& apt clean

RUN mkdir -p /var/www/html && \
	wget "https://github.com/vrana/adminer/releases/download/v4.17.1/adminer-4.17.1.php" -O /var/www/html/index.php

RUN chown -R www-data:www-data /var/www/html

EXPOSE 4000

ENTRYPOINT ["tini", "--"]

CMD ["php", "-S", "0.0.0.0:4000", "-t", "/var/www/html"]
