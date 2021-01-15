FROM tuttleofx/tuttleofx:python2-latest

# File Author / Maintainer
MAINTAINER ShuttleOFX <shuttleofx-dev@googlegroups.com>

# Update repository, Download and Install
RUN apt-get update && \
    apt-get install -y \
      vim \
      wget \
      python-setuptools \
      python-pip \
      nodejs-legacy \
      npm \
      xdg-utils \
      libpython2.7 \
      python-flask \
      docker.io \
      timelimit \
      ruby-full \
      && \
    pip install \
      pymongo \
      python-oauth2 \
      flask-oauthlib \
      && \
    gem install travis -v 1.8.2 --no-rdoc --no-ri && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install last mongodb version to have text search feature
RUN cd /opt/ && \
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-3.0.6.tgz && \
    tar -zxvf mongodb-linux-x86_64-3.0.6.tgz && \
    rm -f mongodb-linux-x86_64-3.0.6.tgz && \
    mv mongodb-linux-x86_64-3.0.6 mongodb && \
    mkdir /opt/mongo-data

# Expose ports
EXPOSE 5000 5004 5002 5005 27017

ENV SHUTTLEOFX_DEV=/opt/shuttleofx_git \
    PATH=${PATH}:/opt/mongodb/bin

COPY . ${SHUTTLEOFX_DEV}

RUN cd ${SHUTTLEOFX_DEV}/shuttleofx_client/ && \
    npm install && \
    npm install -g grunt-cli && \
    grunt build && \
    git config --global user.email shuttleofx@googlegroups.com && \
    git config --global user.name "ShuttleOFX" && \
    chmod 777 ${SHUTTLEOFX_DEV}/start.sh

# Hack for genarts plugins
RUN mkdir -p /usr/genarts/SapphireOFX && cp ${SHUTTLEOFX_DEV}/etc/usr-genarts-SapphireOFX-s_config.text /usr/genarts/SapphireOFX/s_config.text

CMD ["/opt/shuttleofx_git/start.sh"]

