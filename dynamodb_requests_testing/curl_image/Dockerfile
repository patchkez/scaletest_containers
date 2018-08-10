FROM ubuntu:16.04

RUN apt update && \
    apt install -y libcurl4-openssl-dev libgomp1 curl && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -u 4000 -m curl

USER curl
WORKDIR /home/curl

ADD entrypoint.sh /usr/local/bin
ADD start-curl.sh /usr/local/bin

ENTRYPOINT ["entrypoint.sh"]
CMD ["start-curl.sh"]
