FROM geonode/django:geonode
## Install Java
RUN \
  apt-get update -y && \
  apt-get install -y openjdk-7-jdk && \
  rm -rf /var/lib/apt/lists/*

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64

RUN mkdir -p /usr/src/app/
COPY . /usr/src/app/

## Install Ant
ENV ANT_VERSION 1.9.4
RUN cd && \
    wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz

# Removing pre-compiled javascript.
RUN rm -rf /usr/src/app/worldmap/static/worldmap_client/script

WORKDIR /usr/src/app/src/geonode-client/
RUN /opt/ant/bin/ant dist

WORKDIR /usr/src/app
