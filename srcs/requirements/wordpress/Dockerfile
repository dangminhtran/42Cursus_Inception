FROM debian:bullseye

# Update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# Install minimal required packages for WordPress
RUN apt-get install -y \
    curl \
    wget \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-gd \
    php7.4-curl \
    php7.4-zip \
    mariadb-client \
    netcat-traditional \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create WordPress directory with proper permissions
RUN mkdir -p /var/www/wordpress

# Télécharger et installer WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
    && mv /tmp/wordpress/* /var/www/wordpress/ \
    && rm -rf /tmp/wordpress* \
    && chown -R www-data:www-data /var/www/wordpress \
    && chmod -R 755 /var/www/wordpress

# Create PHP-FPM run directory
RUN mkdir -p /run/php \
    && chown -R www-data:www-data /run/php

# Copy the WordPress configuration script
COPY tools/script.sh /tmp/script.sh

# Make script executable
RUN chmod +x /tmp/script.sh

# Expose PHP-FPM port
EXPOSE 9000

# a changer avec le fichier init-wordpress.sh
ENTRYPOINT ["/tmp/script.sh"]

# CMD [ "/usr/sbin/php-fpm7.4", "--nodaemonize", "--fpm-config", "/etc/php/7.4/fpm/php-fpm.conf" ]

