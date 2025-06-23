#!/bin/bash
echo "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD"
echo "MYSQL_DATABASE=$MYSQL_DB"
echo "MYSQL_USER=$MYSQL_USER"
echo "MYSQL_PASSWORD=$MYSQL_PASSWORD"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

service mariadb start
echo -e "${YELLOW}MariaDB is starting...${NC}"
sleep 5

# Function to test connection and determine auth method
test_connection() {
    if mariadb -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}Root connection works with password${NC}"
        MYSQL_CMD="mariadb -u root -p$MYSQL_ROOT_PASSWORD"
        return 0
    elif mariadb -u root -e "SELECT 1;" >/dev/null 2>&1; then
        echo -e "${GREEN}Root connection works without password${NC}"
        MYSQL_CMD="mariadb -u root"
        return 0
    else
        echo -e "${RED}Cannot connect to MariaDB as root!${NC}"
        return 1
    fi
}

# Test connection
if test_connection; then
    echo -e "${BLUE}Creating database...${NC}"
    $MYSQL_CMD -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DB\`;"
    
    echo -e "${BLUE}Creating user...${NC}"
    $MYSQL_CMD -e "CREATE USER IF NOT EXISTS \`$MYSQL_USER\`@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
    
    echo -e "${BLUE}Granting privileges...${NC}"
    $MYSQL_CMD -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DB\`.* TO \`$MYSQL_USER\`@'%';"
    
    echo -e "${BLUE}Flushing privileges...${NC}"
    $MYSQL_CMD -e "FLUSH PRIVILEGES;"
    
    # Set root password if needed
    if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
        echo -e "${YELLOW}Setting root password...${NC}"
        $MYSQL_CMD -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" 2>/dev/null || {
            echo -e "${YELLOW}Root password might already be set${NC}"
        }
    fi
else
    echo -e "${RED}Failed to initialize MariaDB - exiting${NC}"
    exit 1
fi

# Restart MariaDB properly
echo -e "${YELLOW}Restarting MariaDB...${NC}"
if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
    mysqladmin -u root -p"$MYSQL_ROOT_PASSWORD" shutdown 2>/dev/null || service mariadb stop
else
    service mariadb stop
fi

echo -e "${GREEN}Starting MariaDB daemon...${NC}"
# Make sure MariaDB binds to all interfaces
echo "bind-address = 0.0.0.0" >> /etc/mysql/mariadb.conf.d/50-server.cnf
exec mysqld_safe --datadir='/var/lib/mysql'