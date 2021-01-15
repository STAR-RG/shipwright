FROM   ubuntu:precise
MAINTAINER   Ted Dziuba "tdziuba@ebay.com"

RUN apt-get update
RUN apt-get install -y wget language-pack-en
RUN locale-gen en_US

ADD config /

RUN apt-key add /tmp/pgdg-apt-key.asc
RUN apt-get update
RUN apt-get install -y pgdg-keyring postgresql-9.2 postgresql-contrib-9.2 pwgen

ADD config-stage2 /

RUN /bin/docker-postgres-init-devdb


CMD /bin/docker-postgres-dev-server
EXPOSE 5432