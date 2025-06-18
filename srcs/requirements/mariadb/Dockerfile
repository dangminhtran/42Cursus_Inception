FROM debian:bullseye

RUN apt update && apt upgrade && apt install -y \
	mariadb-server \
	mariadb-client \
	&& apt clean

COPY ./conf/script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

EXPOSE 3306

ENTRYPOINT ["/tmp/script.sh"]

CMD ["mysqld_safe", "--user=mysql", "--bind-address=0.0.0.0", "--datadir=/var/lib/mysql"]