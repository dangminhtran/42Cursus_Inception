FROM debian:bullseye

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# # install the required packages
RUN apt-get install -y \
    nginx \
    openssl \
    # curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# create the ssl directory
RUN mkdir -p /etc/nginx/ssl

# generate the ssl certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout \
    /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=dangtran/CN=dangtran.42.fr"

# create a file to store our config nginx files
# RUN mkdir -p /var/config/nginx

# Create WordPress directory with proper permissions
# RUN mkdir -p /var/www/wordpress \
#     && chown -R www-data:www-data /var/www/wordpress \
#     && chmod -R 755 /var/www/wordpress

# Remove default nginx configuration
# RUN rm -f /etc/nginx/sites-enabled/default

# copy the nginx configuration file
# COPY conf/nginx.conf /etc/nginx/conf.d
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Create nginx user if it doesn't exist
# RUN id -u www-data &>/dev/null || useradd -r -s /bin/false www-data

# Health check
# HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
#     CMD curl -f https://localhost:8443 || exit 1

EXPOSE 443
# define the command to run when the container starts
CMD ["nginx", "-g", "daemon off;"]
