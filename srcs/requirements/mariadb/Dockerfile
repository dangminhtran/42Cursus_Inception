FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	mariadb-server \
	mariadb-client \
	tini \
	&& apt clean

COPY ./conf/script.sh /tmp/script.sh
RUN chmod +x /tmp/script.sh

EXPOSE 3306

ENTRYPOINT ["/usr/bin/tini", "--", "/tmp/script.sh"]

CMD ["mysqld"]
