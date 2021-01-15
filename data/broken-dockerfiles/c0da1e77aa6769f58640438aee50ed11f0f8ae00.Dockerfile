#Dockerfile to build a pdf2htmlEx image
FROM debian:wheezy

ENV REFRESHED_AT 20151007

# update debian source list
RUN echo "deb http://ftp.de.debian.org/debian sid main" >> /etc/apt/sources.list && \
    apt-get -qqy update && \
    apt-get -qqy install pdf2htmlex && \
    rm -rf /var/lib/apt/lists/*

VOLUME /pdf
WORKDIR /pdf

CMD ["pdf2htmlEX"]
