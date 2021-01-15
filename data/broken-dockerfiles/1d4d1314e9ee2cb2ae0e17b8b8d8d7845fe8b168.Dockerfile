FROM python:3.6-alpine

RUN apk --update add --virtual build-dependencies \
      python-dev libffi-dev openssl-dev build-base && \
    pip install --upgrade pip cffi cryptography && \
    apk del build-dependencies && \
    apk add --no-cache bash git && \
    rm -rf /var/cache/apk/*

COPY production-requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt
COPY . /app/
WORKDIR /app
