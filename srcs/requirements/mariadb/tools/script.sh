#!/bin/bash

#--------------mariadb initialization--------------#
# Initialize MariaDB data directory if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

#--------------mariadb start--------------#
echo "Starting MariaDB..."
service mysql start
sleep 10

#--------------mariadb config--------------#
# Configure root password (works for fresh installation)
echo "Configuring MariaDB..."

# Try to set root password (for fresh install, root has no password initially)
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';" 2>/dev/null || \
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null || {
    echo "Root password configuration failed"
    exit 1
}

# Create database
echo "Creating database ${MYSQL_DB}..."
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

# Create user
echo "Creating user ${MYSQL_USER}..."
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

# Grant privileges
echo "Granting privileges..."
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"

# Flush privileges
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"

# Shutdown the service to restart with mysqld_safe
echo "Restarting MariaDB with mysqld_safe..."
mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown

# Keep MariaDB running in foreground
echo "Starting MariaDB in safe mode..."
exec mysqld_safe --user=mysql --datadir=/var/lib/mysql