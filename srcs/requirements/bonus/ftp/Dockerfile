FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	vsftpd \
	tini \
	&& apt clean

COPY ./conf/vsftpd.conf /etc/vsftpd.conf
COPY ./conf/vsftpd_conf.sh /usr/local/bin/start_ftp.sh
RUN chmod +x /usr/local/bin/start_ftp.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/start_ftp.sh"]
