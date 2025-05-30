FROM debian:bullseye

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

RUN apt-get -y install wget

# install the required packages
RUN apt-get install -y curl php php7.4-fpm php-mysql mariadb-client
# RUN apt-get install -y php7.4 php-fpm php-mysql mariadb-client

# RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www

# copy the wordpress configuration script to the root directory in the container
COPY tools/script.sh /tmp/script.sh

# change the permission of the script to make it executable
RUN  chmod +x /tmp/script.sh
# RUN		chown -R root:root /var/www/wordpress

# define the entrypoint command to run when the container starts
ENTRYPOINT ["sh", "/tmp/script.sh"]