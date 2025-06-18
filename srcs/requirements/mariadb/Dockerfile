FROM debian:bullseye

RUN apt update -y && apt upgrade -y

RUN apt-get install -y \
	mariadb-server \
	mariadb-client \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# A supprimer car dans .env
# Set environment variables for MySQL
# ENV MYSQL_ROOT_PASSWORD=root
# ENV MYSQL_DATABASE=default_db
# ENV MYSQL_USER=user
# ENV MYSQL_PASSWORD=password

# Ensure the MySQL data directory exists and has the correct permissions
RUN mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /var/lib/mysql \
	&& chmod 750 /var/lib/mysql


# Copy configuration files
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/script.sh /tmp/script.sh

# Set permissions for the script
RUN chmod +x /tmp/script.sh

EXPOSE 3306

ENTRYPOINT ["/tmp/script.sh"]

CMD ["mysqld", '--user=mysql']