# build with: docker build --squash -f etc/Dockerfile-base -t=pombase/canto-base:v9 .

FROM bitnami/minideb:jessie
MAINTAINER Kim Rutherford <kim@pombase.org>

RUN apt-get update; \
  apt-get install -y ntpdate sqlite3 make tar gzip whiptail gcc g++ wget \
    perl git-core libxml2-dev zlib1g-dev libssl-dev \
    libexpat1-dev libpq-dev curl sendmail \
    libpq-dev libxml2-dev zlib1g-dev libssl-dev libexpat1-dev && apt-get clean

RUN apt-get update; \
  apt-get install -y libcatalyst-perl libcatalyst-modules-perl \
    libserver-starter-perl starman \
    libmodule-install-perl libcatalyst-devel-perl liblocal-lib-perl && \
   apt-get clean

RUN curl -L http://cpanmin.us | perl - --self-upgrade

RUN echo installing lib lucene && (cd /tmp/; \
  wget http://ftp.debian.org/debian/pool/main/c/clucene-core/libclucene-dev_0.9.21b-2+b1_amd64.deb && \
  wget http://ftp.debian.org/debian/pool/main/c/clucene-core/libclucene0ldbl_0.9.21b-2+b1_amd64.deb && \
  dpkg -i libclucene0ldbl_0.9.21b-2+b1_amd64.deb libclucene-dev_0.9.21b-2+b1_amd64.deb && \
  rm libclucene0ldbl_0.9.21b-2+b1_amd64.deb libclucene-dev_0.9.21b-2+b1_amd64.deb)

RUN cpanm Lucene

RUN echo deb http://http.debian.net/debian jessie-backports main >> /etc/apt/sources.list; apt update

RUN apt-get -y install -t jessie-backports openjdk-8-jdk

RUN (cd /usr/local/bin/; curl -L http://build.berkeleybop.org/userContent/owltools/owltools > owltools; chmod a+x owltools)

RUN mkdir /tmp/canto
COPY . /tmp/canto/
RUN (cd /tmp/canto; perl Makefile.PL && make installdeps); rm -rf /tmp/canto

RUN rm -rf /root/.local /root/.cpan*

RUN apt-get remove -y wget tar gcc g++ libx11-data libx11-6 x11-common; apt-get autoremove -y
