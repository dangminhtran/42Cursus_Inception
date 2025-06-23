#!/bin/bash

echo "Starting WordPress setup..."

#---------------------------------------------------Wait for MariaDB---------------------------------------------------#
echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

#---------------------------------------------------WP-CLI installation---------------------------------------------------#
echo "Installing WP-CLI..."
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    echo "WP-CLI installed successfully"
else
    echo "WP-CLI already installed"
fi

#---------------------------------------------------WordPress setup---------------------------------------------------#
# Go to WordPress directory
cd /var/www/wordpress

# Set proper permissions
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

# Download WordPress core if not already present
if [ ! -f wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root --locale=fr_FR
    
    echo "Creating wp-config.php..."
    wp core config \
        --dbhost=mariadb:3306 \
        --dbname="$MYSQL_DB" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --allow-root \
        --debug=true 
    
    echo "Installing WordPress..."
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_N" \
        --admin_password="$WP_ADMIN_P" \
        --admin_email="$WP_ADMIN_E" \
        --allow-root
    
    echo "Creating additional WordPress user..."
    wp user create "$WP_U_NAME" "$WP_U_EMAIL" \
        --user_pass="$WP_U_PASS" \
        --role="$WP_U_ROLE" \
        --allow-root
    
    echo "WordPress installation completed!"
else
    echo "WordPress already installed"
fi

#---------------------------------------------------PHP-FPM configuration---------------------------------------------------#
echo "Configuring PHP-FPM..."

# Configure PHP-FPM to listen on all interfaces
sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/7.4/fpm/pool.d/www.conf

# Ensure PHP-FPM can handle connections from any IP
if ! grep -q "listen.allowed_clients" /etc/php/7.4/fpm/pool.d/www.conf; then
    echo "listen.allowed_clients = any" >> /etc/php/7.4/fpm/pool.d/www.conf
fi

# Create wp-config.php from sample if it doesn't exist
if [ ! -f wp-config.php ] && [ -f wp-config-sample.php ]; then
    sed -i "s/username_here/$MYSQL_USER/g" wp-config-sample.php
    sed -i "s/password_here/$MYSQL_PASSWORD/g" wp-config-sample.php
    # sed -i "s/localhost/mariadb/g" wp-config-sample.php
    sed -i "s/database_name_here/$MYSQL_DB/g" wp-config-sample.php
    cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php
fi

echo "PHP-FPM configuration completed!"
#---------------------------------------------------Start PHP-FPM---------------------------------------------------#
echo "Starting PHP-FPM..."

# Create PID directory
mkdir -p /var/run/php-fpm

# Set proper ownership
chown -R www-data:www-data /var/www/wordpress
chown -R www-data:www-data /run/php

# Start PHP-FPM in foreground
echo "PHP-FPM starting in foreground mode..."
exec /usr/sbin/php-fpm7.4 -F