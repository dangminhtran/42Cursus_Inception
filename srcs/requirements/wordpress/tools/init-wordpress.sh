#!/bin/bash

echo "Starting WordPress PHP-FPM container..."
# Attendre que la base de données soit prête (si nécessaire)
if [ -n ${MYSQL_USER} ] && [ ${MYSQL_USER} != "localhost" ]; then
    echo "Waiting for database at `${MYSQL_USER}`: on port-3306..."
    while ! nc -z \$DB_HOST \${DB_PORT:-3306}; do
        sleep 1
        echo "Still waiting for database..."
    done
    echo "Database is ready!"
fi

# Créer wp-config.php si il n'existe pas
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Creating wp-config.php..."
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
    
    # Configuration de base de données
    sed -i "s/database_name_here/\${DB_NAME:-wordpress}/" /var/www/html/wp-config.php
    sed -i "s/username_here/\${DB_USER:-wordpress}/" /var/www/html/wp-config.php
    sed -i "s/password_here/\${DB_PASSWORD:-wordpress}/" /var/www/html/wp-config.php
    sed -i "s/localhost/\${DB_HOST:-localhost}/" /var/www/html/wp-config.php
    
    # Générer les clés de sécurité WordPress
    if command -v wp >/dev/null 2>&1; then
        echo "Generating WordPress security keys..."
        wp config shuffle-salts --path=/var/www/html --allow-root || true
    fi
fi

# Fixer les permissions
echo "Setting up permissions..."
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# Créer les répertoires nécessaires
mkdir -p /var/run/php
chown www-data:www-data /var/run/php
echo "WordPress PHP-FPM is ready!"
echo "Connecting to database: \${DB_HOST:-localhost}:\${DB_PORT:-3306}"
echo "Database name: \${DB_NAME:-wordpress}"
exec "\$@"