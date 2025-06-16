# Utiliser l'image officielle Debian comme base
FROM debian:bullseye-slim
# Installer les dépendances nécessaires
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    netcat
# Ajouter la clé GPG et le repository d'Ondřej Surý pour PHP
RUN wget -qO /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
# Mettre à jour les paquets et installer PHP-FPM avec les extensions WordPress
RUN apt-get update && apt-get install -y \
    php8.3 \
    php8.3-fpm \
    php8.3-mysql \
    php8.3-curl \
    php8.3-gd \
    php8.3-mbstring \
    php8.3-xml \
    php8.3-zip \
    php8.3-intl \
    php8.3-bcmath \
    php8.3-opcache \
    php8.3-imagick \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# Télécharger et installer WordPress
RUN wget https://wordpress.org/latest-fr_FR.tar.gz -O /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /tmp \
    && mv /tmp/wordpress/* /var/www/html/ \
    && rm -rf /tmp/wordpress* \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html
# Installer WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.9.0/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
# Configuration PHP-FPM pour écouter sur toutes les interfaces
RUN sed -i 's/listen = \/run\/php\/php8.3-fpm.sock/listen = 0.0.0.0:9000/' /etc/php/8.3/fpm/pool.d/www.conf \
    && sed -i 's/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = any/' /etc/php/8.3/fpm/pool.d/www.conf \
    && sed -i 's/;clear_env = no/clear_env = no/' /etc/php/8.3/fpm/pool.d/www.conf
# Configuration PHP pour WordPress
RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 64M/' /etc/php/8.3/fpm/php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 64M/' /etc/php/8.3/fpm/php.ini \
    && sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/8.3/fpm/php.ini \
    && sed -i 's/memory_limit = 128M/memory_limit = 256M/' /etc/php/8.3/fpm/php.ini
# Configuration pour les logs PHP-FPM
RUN sed -i 's/;log_level = notice/log_level = notice/' /etc/php/8.3/fpm/php-fpm.conf \
    && sed -i 's/;error_log = log\/php8.3-fpm.log/error_log = \/proc\/self\/fd\/2/' /etc/php/8.3/fpm/php-fpm.conf
# Configuration du pool PHP-FPM pour les logs
RUN sed -i 's/;access.log = log\/\$pool.access.log/access.log = \/proc\/self\/fd\/2/' /etc/php/8.3/fpm/pool.d/www.conf \
    && sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' /etc/php/8.3/fpm/pool.d/www.conf
# Script d'initialisation WordPress
COPY <<EOF /usr/local/bin/init-wordpress.sh
#!/bin/bash
set -e
echo "Starting WordPress PHP-FPM container..."
# Attendre que la base de données soit prête (si nécessaire)
if [ -n "\$DB_HOST" ] && [ "\$DB_HOST" != "localhost" ]; then
    echo "Waiting for database at \$DB_HOST:\${DB_PORT:-3306}..."
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
EOF
RUN chmod +x /usr/local/bin/init-wordpress.sh
# Script de santé pour vérifier que PHP-FPM fonctionne
COPY <<EOF /usr/local/bin/healthcheck.sh
#!/bin/bash
# Vérifier que PHP-FPM écoute sur le port 9000
nc -z localhost 9000 && echo "PHP-FPM is running" || exit 1
EOF
RUN chmod +x /usr/local/bin/healthcheck.sh
# Variables d'environnement par défaut
ENV DB_HOST=db
ENV DB_NAME=wordpress
ENV DB_USER=wordpress
ENV DB_PASSWORD=wordpress
ENV DB_PORT=3306
# Exposer le port PHP-FPM
EXPOSE 9000
# Définir le répertoire de travail
WORKDIR /var/www/html
# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh
# Point d'entrée
ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]
# Commande par défaut pour démarrer PHP-FPM
CMD ["/usr/sbin/php-fpm8.3", "--nodaemonize", "--fpm-config", "/etc/php/8.3/fpm/php-fpm.conf"]