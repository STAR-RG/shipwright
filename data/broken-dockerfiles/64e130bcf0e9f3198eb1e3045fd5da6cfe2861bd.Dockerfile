FROM ubuntu:14.04
MAINTAINER Joseph Scavone
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update ;\
    apt-get install -y software-properties-common ;\
    add-apt-repository ppa:brightbox/ruby-ng-experimental ;\
    apt-get update ;\
    apt-get install -y ruby2.3 ruby2.3-dev build-essential curl libreadline-dev libcurl4-gnutls-dev libpq-dev libxml2-dev libxslt1-dev zlib1g-dev libssl-dev git-core libmagickwand-dev libopencv-dev python-opencv postgresql-client

RUN \
    cd /opt ;\
    git clone https://github.com/feedbin/feedbin.git ;\
    cd feedbin ;\
    gem install bundler redis

RUN \
    cd /opt/feedbin ;\
    bundle

ADD config/database.yml /opt/feedbin/config/database.yml
ADD config/environments/production.rb /opt/feedbin/config/environments/production.rb
ADD startup.sh /feedbin-start

CMD ["/bin/bash", "/feedbin-start"]

EXPOSE 9292
