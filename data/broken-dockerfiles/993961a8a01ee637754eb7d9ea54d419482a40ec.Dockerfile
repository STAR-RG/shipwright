FROM debian:jessie
MAINTAINER espen@mrfjo.org
ENV LC_ALL C
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://packages.linuxmint.com debian import" >> /etc/apt/sources.list && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list && \
    sed -i  "s/jessie main/jessie main contrib non-free/" /etc/apt/sources.list && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get update && \
    apt-get install --no-install-recommends --force-yes -y -q git python python-setuptools libyaml-dev libpq-dev python-dev libpcap-dev net-tools firefox xvfb graphviz python-yara ca-certificates python-pymongo python-dnspython python-yaml python-pydot python-configobj python-simplejson build-essential python-pymongo-ext python-gridfs geoip-database-contrib python-xvfbwrapper libdbus-glib-1-2 flashplugin-nonfree oracle-java8-installer oracle-java8-set-default libasound2 && \
    cd /opt && git clone https://github.com/espenfjo/FjoSpidie.git

WORKDIR /opt/FjoSpidie
RUN python ez_setup.py install && \
    cp fjospidie.conf.dist fjospidie.conf && \
    cp lib/browsermob/uas.xml /tmp

ENTRYPOINT ["./entrypoint.sh"]
