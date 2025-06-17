#!/bin/bash

mkdir -p /var/run/vsftpd/empty

if ! id "$FTP_USER" &>/dev/null; then
	useradd -m -d /var/www/wordpress -s /bin/bash "$FTP_USER" &&
		echo "$FTP_USER:$FTP_PASSWORD" | chpasswd

	echo "$FTP_USER" | tee -a /etc/vsftpd.userlist &>/dev/null
fi

echo "FTP started on :21"
exec vsftpd /etc/vsftpd.conf
