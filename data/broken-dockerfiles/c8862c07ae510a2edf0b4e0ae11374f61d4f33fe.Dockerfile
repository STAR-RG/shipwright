
FROM alpine:latest

RUN apk add --update \
    python \
    groff \
    py2-pip && \
    adduser -D aws

ENV PAGER='cat'

WORKDIR /home/aws

RUN mkdir aws && \
    pip install --upgrade pip && \
    pip install awscli

USER aws
