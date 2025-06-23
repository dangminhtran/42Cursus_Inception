FROM debian:bullseye

RUN apt update -y && apt upgrade -y

RUN apt-get install -y \
	mariadb-server \
	mariadb-client \
	tini \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure the MySQL data directory exists and has the correct permissions
RUN mkdir -p /var/lib/mysql \
	&& chown -R mysql:mysql /var/lib/mysql \
	&& chmod 777 /var/lib/mysql


# Copy configuration files
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/script.sh /tmp/script.sh

# Set permissions for the script
RUN chmod +x /tmp/script.sh

EXPOSE 3306

# ENTRYPOINT ["/tmp/script.sh"]
ENTRYPOINT ["/usr/bin/tini", "--", "/tmp/script.sh"]

# CMD ["mysqld", '--user=mysql']
CMD ["mysqld"]