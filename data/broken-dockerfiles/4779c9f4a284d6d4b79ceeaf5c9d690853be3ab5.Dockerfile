# usage: docker build -t wgame/python:v1 .
FROM python:3.7-alpine
COPY requirements.txt /tmp/
# g++ gcc libffi-dev openssl-dev
RUN apk add --no-cache python3-dev tzdata && \
    ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    pip3 install -r /tmp/requirements.txt && rm -rf /var/lib/apt/lists/*
# ENV TZ Asia/Shanghai
