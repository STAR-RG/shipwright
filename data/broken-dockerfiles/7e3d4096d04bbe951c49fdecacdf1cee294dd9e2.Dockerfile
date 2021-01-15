FROM openjdk:8-slim

RUN apt update && apt -y install git rsync zip libc++-dev squashfs-tools make gcc zlib1g-dev

WORKDIR /
COPY haystack /haystack
COPY simple-deodexer /simple-deodexer
COPY vdexExtractor /vdexExtractor
RUN cd /vdexExtractor && ./make.sh

ADD *.sh ./

ENV SAILFISH 172.28.172.1
CMD ["bash", "./run.sh"]
