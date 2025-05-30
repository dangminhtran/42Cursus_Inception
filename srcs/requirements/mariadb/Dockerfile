FROM debian:bullseye

# update and upgrade the system
RUN apt-get update && apt-get upgrade -y

# # install the required packages
RUN apt-get install mariadb-server -y 
# netcat a la fin de la ligne ?

# copy file from host to container
# COPY ./mdb-conf.sh /mdb-conf.sh
COPY conf/50-server.cnf	/etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/script.sh /tmp/script.sh

# set permissions to the file
# RUN chmod +x /mdb-conf.sh
RUN chmod +x /tmp/script.sh

# define entrypoint command to run when the container starts
ENTRYPOINT ["sh", "/tmp/script.sh"]