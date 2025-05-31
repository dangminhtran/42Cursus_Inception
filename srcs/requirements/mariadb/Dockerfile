FROM debian:bullseye

# Update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# Install MariaDB server and required tools
RUN apt-get install -y \
    mariadb-server \
    mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create the required directories with proper permissions
RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 777 /var/run/mysqld

# Copy configuration files
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/script.sh /tmp/script.sh

# Set proper permissions
RUN chmod +x /tmp/script.sh \
    && chown -R mysql:mysql /var/lib/mysql

# Expose MariaDB port
EXPOSE 3306

# Define entrypoint
ENTRYPOINT ["bash", "/tmp/script.sh"]