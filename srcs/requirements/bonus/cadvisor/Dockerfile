FROM debian:bullseye

RUN apt update -y && apt upgrade -y && apt install -y \
	wget \
	&& apt clean

RUN wget "https://github.com/google/cadvisor/releases/download/v0.49.2/cadvisor-v0.49.2-linux-amd64" -O /usr/local/bin/cadvisor
# RUN wget "https://github.com/google/cadvisor/releases/download/v0.49.2/cadvisor-v0.49.2-linux-arm64" -O /usr/local/bin/cadvisor

RUN chmod +x /usr/local/bin/cadvisor

EXPOSE 8080

CMD ["/usr/local/bin/cadvisor", "-port=8080"]
