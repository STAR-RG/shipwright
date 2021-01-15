# Ubuntu PostgreSQL.

FROM ubuntu:14.04
MAINTAINER Thomas Quintana <thomas@bettervoice.com>

# Install.
RUN apt-get update && apt-get install -y daemontools libffi-dev libssl-dev lzop postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3 postgresql-9.3-pgpool2 postgresql-9.3-postgis-2.1 pv python python-dev python-pip
ADD bin/get-pip.py /usr/local/bin/get-pip.py
RUN python /usr/local/bin/get-pip.py
RUN pip install --upgrade six
RUN pip install Jinja2 wal-e

# Post Install Configuration.
ADD bin/start-postgres /usr/bin/start-postgres
RUN chmod +x /usr/bin/start-postgres
ADD bin/heartbeat.template /usr/share/postgresql/9.3/heartbeat.template
ADD conf/postgresql.conf.template /usr/share/postgresql/9.3/postgresql.conf.template
ADD conf/pg_hba.conf.template /usr/share/postgresql/9.3/pg_hba.conf.template
ADD conf/recovery.conf.template /usr/share/postgresql/9.3/recovery.conf.template

# Open the container up to the world.
EXPOSE 5432/tcp

# Start PostgreSQL.
CMD start-postgres