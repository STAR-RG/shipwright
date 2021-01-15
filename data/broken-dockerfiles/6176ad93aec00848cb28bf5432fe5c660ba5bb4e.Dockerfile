FROM ubuntu:16.04
MAINTAINER Jadson Lourenço <jadsonlourenco@gmail.com>
LABEL Description="Percona MongoRocks"

ENV DEBIAN_FRONTEND="noninteractive" \
  AUTH="yes" \
  ADMIN_USER="admin" \
  ADMIN_PASS="admin" \
  DBPATH="/data/db" \
  DB_USER="user" \
  DB_PASS="password"

COPY ./set_auth.sh /
COPY ./entrypoint.sh /
RUN chmod +x /entrypoint.sh && chmod +x /set_auth.sh

RUN apt-get update && apt-get install -y curl libpcap0.8 && \
  curl -s -o /tmp/percona-server-mongodb.tar https://www.percona.com/downloads/percona-server-mongodb-LATEST/percona-server-mongodb-3.4.7-1.8/binary/debian/xenial/x86_64/percona-server-mongodb-3.4.7-1.8-rae48d6e032-xenial-x86_64-bundle.tar && \
  tar -xf /tmp/percona-server-mongodb.tar -C /tmp/ && \
  dpkg -i /tmp/percona-server-mongodb-*.deb && \
  rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*

ENTRYPOINT ["/entrypoint.sh"]
