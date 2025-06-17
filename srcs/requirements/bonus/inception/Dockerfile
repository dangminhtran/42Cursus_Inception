FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	nginx \
	&& apt clean

RUN mkdir -p /var/www/html

COPY ./conf/inception.png /var/www/html/inception.png
COPY ./conf/index.html /var/www/html/index.html

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
