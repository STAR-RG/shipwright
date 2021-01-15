FROM ubuntu:16.04
WORKDIR /root

RUN apt-get update
RUN apt-get -qq upgrade -y
RUN apt-get -qq install -y ruby-build autoconf subversion bison wget sqlite3 libsqlite3-dev

ENV PATH /root/.rbenv/shims:$PATH
RUN rbenv install 1.8.7-p375
RUN rbenv local 1.8.7-p375

RUN gem update --system 1.6
RUN gem install sqlite3 --no-rdoc --no-ri
RUN gem install rdoc --version=4.2.2 --no-rdoc --no-ri
RUN gem install hpricot --no-rdoc --no-ri
RUN gem install rack --version=1.0.0 --no-rdoc --no-ri
RUN gem install rake --version=10.1.1 --no-rdoc --no-ri

RUN mkdir /db
VOLUME /db

WORKDIR /app

ADD . /app

RUN cp config/database.example.yml config/database.yml
RUN sed -i 's/mysql/sqlite3/' config/database.yml
RUN sed -i 's/limecast_/\/db\/limecast_/' config/database.yml

RUN rbenv rehash

EXPOSE 3000
CMD script/server
