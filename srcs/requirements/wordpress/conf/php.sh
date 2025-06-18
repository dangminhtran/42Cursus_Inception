#!/bin/sh

php_version=$(php -v | head -n 1 | grep -oP 'PHP \K[0-9]+\.[0-9]+')

if ! grep -q "listen = 0.0.0.0:9000" /etc/php/"$php_version"/fpm/pool.d/www.conf; then
	echo "listen = 0.0.0.0:9000" >>/etc/php/"$php_version"/fpm/pool.d/www.conf
fi

: "${MYSQL_HOST:?Environment variable MYSQL_HOST not set}"
: "${MYSQL_DATABASE:?Environment variable MYSQL_DATABASE not set}"
: "${MYSQL_USER:?Environment variable MYSQL_USER not set}"
: "${MYSQL_PASSWORD:?Environment variable MYSQL_PASSWORD not set}"

generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1
}

cat <<EOT >> wp-config.php
// based on https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
define( 'DB_NAME', '$MYSQL_DATABASE' );
define( 'DB_USER', '$MYSQL_USER' );
define( 'DB_PASSWORD', '$MYSQL_PASSWORD' );
define( 'DB_HOST', '$MYSQL_HOST' );

define( 'AUTH_KEY',         '$(generate_random_string)');
define( 'SECURE_AUTH_KEY',  '$(generate_random_string)');
define( 'LOGGED_IN_KEY',    '$(generate_random_string)');
define( 'NONCE_KEY',        '$(generate_random_string)');
define( 'AUTH_SALT',        '$(generate_random_string)');
define( 'SECURE_AUTH_SALT', '$(generate_random_string)');
define( 'LOGGED_IN_SALT',   '$(generate_random_string)');
define( 'NONCE_SALT',       '$(generate_random_string)');

if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOT

chown -R www-data:www-data /var/www/wordpress

exec php-fpm"$php_version" -F
