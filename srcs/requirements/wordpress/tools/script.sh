#!/bin/bash
echo "Beginning the script.sh of Wordpress"

# Colors for output (fix: no spaces around = and proper quotes)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

if ! grep -q "listen = 0.0.0.0:9000" /etc/php/7.4/fpm/pool.d/www.conf; then
    echo "listen = 0.0.0.0:9000" >>/etc/php/7.4/fpm/pool.d/www.conf
fi

echo -e "${RED}Replacing database username...${NC}"
sed -i "s/username_here/$MYSQL_USER/g" wp-config-sample.php

echo -e "${GREEN}Replacing database password...${NC}"
sed -i "s/password_here/$MYSQL_PASSWORD/g" wp-config-sample.php

echo -e "${YELLOW}Replacing database hostname...${NC}"
sed -i "s/dangtran-mariadb/$MYSQL_HOSTNAME/g" wp-config-sample.php

echo -e "${BLUE}Replacing database name...${NC}"
sed -i "s/database_name_here/$MYSQL_DB/g" wp-config-sample.php

echo -e "${PURPLE}Copying wp-config file...${NC}"
cp /var/www/wordpress/wp-config-sample.php /var/www/wordpress/wp-config.php

echo -e "${CYAN}Setting ownership...${NC}"
chown -R www-data:www-data /var/www/wordpress

echo -e "${GREEN}Starting PHP-FPM...${NC}"
exec php-fpm7.4 -F