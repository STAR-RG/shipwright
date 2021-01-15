FROM cthulhuology/postgresql
MAINTAINER Dave Goehrig <dave@dloh.org>

RUN yum install -y pdns bind-utils pdns-backend-postgresql.x86_64


ADD ./pdns.conf /etc/pdns/pdns.conf
ADD ./pdns.sql /pdns.sql
ADD ./start.sh /start.sh
RUN chmod u+x /start.sh

RUN yum install -y postgresql93-devel nodejs npm
RUN PATH=/usr/pgsql-9.3/bin/:$PATH npm install pgproc.http

EXPOSE 53
EXPOSE 53/udp
EXPOSE 8053
EXPOSE 5380

CMD ./start.sh
