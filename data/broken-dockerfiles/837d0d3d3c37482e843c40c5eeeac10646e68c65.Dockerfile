FROM ubuntu:14.04

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get upgrade -y && \
  DEBIAN_FRONTEND=noninteractive apt-get -y install \
    build-essential \
    curl \
    git-core \
    libcurl4-openssl-dev \
    libreadline-dev \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    redis-server \
    maven \
    mininet \
    lsof \
    openjdk-7-jdk \
    python2.7-dev \
    python-setuptools \
    libsqlite3-dev \
    libpcap-dev \
    zlib1g-dev && \    
    curl -O http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p645.tar.gz && \
    tar -zxvf ruby-2.0.0-p645.tar.gz && \
    cd ruby-2.0.0-p645 && \
    ./configure --disable-install-doc && \
    make && \
    make install && \
    cd .. && \
    rm -r ruby-2.0.0-p645 ruby-2.0.0-p645.tar.gz && \
    echo 'gem: --no-document' > /usr/local/etc/gemrc

#Install Bundler for each version of ruby
RUN \
  echo 'gem: --no-rdoc --no-ri' >> /.gemrc && \
  gem install bundler

  
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64 
ENV HOME /root 
WORKDIR /root

RUN easy_install pip
RUN pip install msgpack-python==0.4.6 redis==2.10.3 futures==2.2.0 mock==1.0.1 coverage==4.0a5 kazoo==2.2.1

RUN git clone https://github.com/o3project/odenos.git
RUN cd odenos && mvn install && bundle install && \
    cd etc && echo "PROCESS romgr2,python,apps/python/sample_components" >> odenos.conf

RUN git clone http://github.com/trema/trema-edge.git
RUN cd trema-edge && git checkout -b 148acb9cd7f654020098a5e769bfedad273a687b && bundle install && rake

RUN curl -O http://neo4j.com/artifact.php?name=neo4j-community-2.2.3-unix.tar.gz && \
    tar -zxvf artifact.php?name=neo4j-community-2.2.3-unix.tar.gz && \
    rm -r artifact.php?name=neo4j-community-2.2.3-unix.tar.gz

RUN echo "service redis-server restart" >> ~/.bashrc
RUN echo "service openvswitch-switch restart" >> ~/.bashrc
RUN echo "org.neo4j.server.webserver.address=0.0.0.0" >> ./neo4j-community-2.2.3/conf/neo4j-server.properties
RUN sed -i -e "s/dbms.security.auth_enabled=true/dbms.security.auth_enabled=false/g" ~/neo4j-community-2.2.3/conf/neo4j-server.properties 
RUN echo "neo4j-community-2.2.3/bin/neo4j start" >> ~/.bashrc
