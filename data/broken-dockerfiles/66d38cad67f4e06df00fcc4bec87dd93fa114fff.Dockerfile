FROM ubuntu
MAINTAINER Jioh L. Jung "ziozzang@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /opt && \
    apt-get update && \
    apt upgrade -fy && \
    apt-get install -y \
       python-ldap python-flask python-flask-restful python-netaddr && \
    apt-get autoremove -fy && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/
COPY ./src/* /opt/

EXPOSE 5000
CMD ["/usr/bin/python", "/opt/server.py"]
