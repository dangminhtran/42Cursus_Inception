#!/bin/bash
set -e

echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
echo "MYSQL_DATABASE=$MYSQL_DB"
echo "MYSQL_USER=$MYSQL_USER"
echo "MYSQL_PASSWORD=$MYSQL_PASSWORD"

# Ensure required variables are set
: "${MYSQL_DB:?Environment variable MYSQL_DB not set}"
: "${MYSQL_USER:?Environment variable MYSQL_USER not set}"
: "${MYSQL_PASSWORD:?Environment variable MYSQL_PASSWORD not set}"

#--------------mariadb start--------------#
echo "Starting MariaDB..."
service mariadb start

# Wait for MariaDB to be fully ready
echo "Waiting for MariaDB to be fully ready..."
while ! mysqladmin ping --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done
echo "MariaDB is ready!"

# Check if root password is set and use it for authentication
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    # Try to set root password (will fail if already set, which is fine)
    echo "Setting root password..."
    mysqladmin -u root password "$MYSQL_ROOT_PASSWORD" 2>/dev/null || {
        echo "Root password already set or failed to set, continuing..."
    }
    
    # Use password for all operations
    echo "Creating database ${MYSQL_DB}..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;" 2>/dev/null || {
        echo "Database creation failed with password, trying without password..."
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"
    }

    echo "Creating user ${MYSQL_USER}..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';" 2>/dev/null || {
        mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
    }

    # Grant privileges
    echo "Granting privileges..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';" 2>/dev/null || {
        mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"
    }
    
    echo "Flushing privileges..."
    mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;" 2>/dev/null || {
        mysql -u root -e "FLUSH PRIVILEGES;"
    }

    # Shutdown with password
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown 2>/dev/null || mysqladmin -u root shutdown
else
    # Create the database and user without root password
    echo "Creating database ${MYSQL_DB}..."
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

    echo "Creating user ${MYSQL_USER}..."
    mysql -u root -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

    # Grant privileges
    echo "Granting privileges..."
    mysql -u root -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DB}\`.* TO \`${MYSQL_USER}\`@'%';"
    echo "Flushing privileges..."
    mysql -u root -e "FLUSH PRIVILEGES;"

    # Shutdown without password
    mysqladmin -u root shutdown
fi

# restart mariadb
echo "Restarting MariaDB with mysqld_safe..."
mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'