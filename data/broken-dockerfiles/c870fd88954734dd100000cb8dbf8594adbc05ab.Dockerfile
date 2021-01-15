FROM java:8-jdk

MAINTAINER Bulktrade GmbH (info@bulktrade.org)

ENV ORIENTDB_VERSION 2.1.3

RUN mkdir /orientdb && \
  wget -O orientdb-community-$ORIENTDB_VERSION.tar.gz "http://orientdb.com/download.php?email=unknown@unknown.com&file=orientdb-community-$ORIENTDB_VERSION.tar.gz&os=linux" \
  && tar -xvzf orientdb-community-$ORIENTDB_VERSION.tar.gz -C /orientdb --strip-components=1\
  && rm orientdb-community-$ORIENTDB_VERSION.tar.gz \
  && rm -rf /orientdb/databases/*

VOLUME ["/orientdb/backup", "/orientdb/databases", "/orientdb/config"]

EXPOSE 2424 2480

WORKDIR /orientdb
USER root

ADD run.sh /run.sh
ADD cleanup.sh /cleanup.sh
CMD ["/run.sh"]