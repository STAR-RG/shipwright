FROM ubuntu:14.04
MAINTAINER Henning Jacobs <henning@jacobs1.de>

RUN apt-get update
RUN apt-get -y install python-lxml pep8 pyflakes nodejs npm nailgun python-sqlparse python-yaml
RUN npm install -g jshint

ADD . /codevalidator
ADD pgsqlparser/PgSqlParser /opt/codevalidator/PgSqlParser

VOLUME ["/workdir"]

ENTRYPOINT ["/codevalidator/codevalidator.py"]
