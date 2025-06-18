#!/bin/bash
# Initialiser la base de données si elle n'existe pas déjà
if [ ! -d "/var/lib/mysql/$MYSQL_DATABASE" ]; then

  : "${MYSQL_DATABASE:?Environment variable MYSQL_DATABASE not set}"
  : "${MYSQL_USER:?Environment variable MYSQL_USER not set}"
  : "${MYSQL_PASSWORD:?Environment variable MYSQL_PASSWORD not set}"

    # Démarrer le serveur MySQL
    service mariadb start

    # Créer la base de données et l'utilisateur
    mariadb -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
    mariadb -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    mariadb -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"

    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        # Changer le mot de passe root
        mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
    fi

    mariadb -e "FLUSH PRIVILEGES;"

    # Arrêter le serveur MySQL
    service mariadb stop
fi

exec "$@"