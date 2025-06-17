#!/bin/bash
set -e

service mariadb start
sleep 5

# Ensure required variables are set
: "${MYSQL_DATABASE:?Environment variable MYSQL_DATABASE not set}"
: "${MYSQL_USER:?Environment variable MYSQL_USER not set}"
: "${MYSQL_PASSWORD:?Environment variable MYSQL_PASSWORD not set}"

mariadb -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`$MYSQL_USER\`@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO \`$MYSQL_USER\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
	mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
fi

mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown

mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'