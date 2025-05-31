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
        --allow-root
    
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

# Backup original configuration
cp /etc/php/7.4/fpm/pool.d/www.conf /etc/php/7.4/fpm/pool.d/www.conf.backup

# Configure PHP-FPM to listen on port 9000
sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf

# Configure PHP-FPM to listen on all interfaces
sed -i 's|;listen.owner = www-data|listen.owner = www-data|g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's|;listen.group = www-data|listen.group = www-data|g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's|;listen.mode = 0660|listen.mode = 0660|g' /etc/php/7.4/fpm/pool.d/www.conf

# Set proper user and group
sed -i 's|user = www-data|user = www-data|g' /etc/php/7.4/fpm/pool.d/www.conf
sed -i 's|group = www-data|group = www-data|g' /etc/php/7.4/fpm/pool.d/www.conf

# PHP configuration for WordPress
cat >> /etc/php/7.4/fpm/php.ini <<EOF

; WordPress optimizations
upload_max_filesize = 32M
post_max_size = 32M
memory_limit = 256M
max_execution_time = 300
max_input_vars = 3000
EOF

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