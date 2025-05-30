FROM debian:bullseye

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# # install the required packages
RUN apt-get install -y nginx openssl 


# install vim
# RUN apt-get install -y vim

# create the ssl directory
RUN mkdir -p /etc/nginx/ssl

# generate the ssl certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout \
    /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=login.42.fr/UID=dangtran"

# create a file to store our config nginx files
RUN mkdir -p /var/config/nginx

# copy the nginx configuration file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# create the wordpress directory
# RUN mkdir -p /var/www/wordpress

# change the root
RUN mkdir -p /var/www/html
RUN chmod 755 /var/www/html

# change the owner of the wordpress directory to www-data
RUN chown -R www-data:www-data /var/www/html
# RUN chown -R www-data:www-data /var/www/wordpress

EXPOSE 443
# define the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]