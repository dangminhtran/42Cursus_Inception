#!/bin/bash

# to_config = 0

#--------------mariadb initialization--------------#
# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then 
    echo "Initializing MariaDB data directory..."
    mariadb_install_db --user=mariadb --datadir=/var/lib/mariadb
#    to_config = 1
fi

#--------------mariadb start--------------#
echo "Starting MariaDB..."
service mariadb start
sleep 10

#--------------mariadb config--------------#
# Configure root password (works for fresh installation)
# if [ $to_config -eq 1 ]; then
    echo "Configuring MariaDB root password..."
    MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-"root"}
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
    echo "Configuring MariaDB..."

    # Try to set root password (for fresh install, root has no password initially)
    mariadb -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" 2>/dev/null || \
    mariadb -u root -p ${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null || {
        echo "Root password configuration failed"
        exit 1
    }

    # Create database
    echo "Creating database ${MYSQL_DB}..."
    mariadb -u root -p ${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

    # Create user
    echo "Creating user ${MYSQL_USER}..."
    mariadb -u root -p ${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    # Grant privileges
    echo "Granting privileges..."
    mariadb -u root -p ${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"

    # Flush privileges
    mariadb -u root -p ${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

    # Shutdown the service to restart with mysqld_safe
    echo "Restarting MariaDB with mysqld_safe..."
    mysqladmin -u root -p ${MYSQL_ROOT_PASSWORD} shutdown

# fi

# Keep MariaDB running in foreground
echo "Starting MariaDB in safe mode..."
exec mysqld_safe --user=mariadb --datadir=/var/lib/mariadb