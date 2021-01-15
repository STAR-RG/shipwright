FROM alpine:latest

ENV DEBIAN_FRONTEND noninteractive

RUN apk add --update \
		make \
        python \
        py-pip 

RUN pip install nose coverage

RUN mkdir -p /data/bin
RUN mkdir -p /data/scrapy-dblite

ADD scripts/run-as.sh /data/bin/
RUN chmod +x /data/bin/*.sh
