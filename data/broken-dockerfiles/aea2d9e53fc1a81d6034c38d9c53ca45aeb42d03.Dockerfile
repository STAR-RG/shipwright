#
# Dockerfile - Codis
#
# - Build
# docker build --rm -t codis:latest .
#
# - Run
# docker run -d --name="codis" -h "codis" codis:latest

# Use the base images
FROM ubuntu:14.04
MAINTAINER Yongbok Kim <ruo91@yongbok.net>

# Change the repository
RUN sed -i 's/archive.ubuntu.com/kr.archive.ubuntu.com/g' /etc/apt/sources.list

# The last update and install package for docker
RUN apt-get update && apt-get install -y supervisor git-core curl build-essential openjdk-7-jdk

# Variable
ENV SRC_DIR /opt
WORKDIR $SRC_DIR

# GO Language
ENV GO_ARCH linux-amd64
ENV GOROOT $SRC_DIR/go
ENV GOPATH $SRC_DIR/go_path
ENV PATH $PATH:$GOROOT/bin
RUN curl -XGET https://github.com/golang/go/tags | grep tag-name > /tmp/golang_tag \
 && sed -e 's/<[^>]*>//g' /tmp/golang_tag > /tmp/golang_ver \
 && GO_VER=`sed -e 's/      go/go/g' /tmp/golang_ver | head -n 1` && rm -f /tmp/golang_* \
 && curl -LO "https://storage.googleapis.com/golang/$GO_VER.$GO_ARCH.tar.gz" \
 && tar -C $SRC_DIR -xzf go*.tar.gz && rm -rf go*.tar.gz \
 && echo '' >> /etc/profile \
 && echo '# Golang' >> /etc/profile \
 && echo "export GOROOT=$GOROOT" >> /etc/profile \
 && echo "export GOPATH=$GOPATH" >> /etc/profile \
 && echo 'export PATH=$PATH:$GOROOT/bin' >> /etc/profile \
 && echo '' >> /etc/profile

# ZooKeeper
ENV ZK_VER 3.4.6
ENV ZK_HOME $SRC_DIR/zookeeper
ENV PATH $PATH:$ZK_HOME/bin
ENV ZK_URL http://apache.mirror.cdnetworks.com/zookeeper/stable
RUN curl -LO "$ZK_URL/zookeeper-$ZK_VER.tar.gz" \
 && tar xzvf zookeeper-$ZK_VER.tar.gz \
 && mv zookeeper-$ZK_VER $SRC_DIR/zookeeper \
 && rm -f zookeeper-$ZK_VER.tar.gz \
 && echo '# ZooKeeper' >> /etc/profile \
 && echo "export ZK_HOME=$ZK_HOME" >> /etc/profile \
 && echo 'export PATH=$PATH:$ZK_HOME/bin' >> /etc/profile
ADD conf/zoo.cfg $ZK_HOME/conf/zoo.cfg

# Codis
ENV CODIS_HOME $SRC_DIR/codis
ENV PATH $PATH:$CODIS_HOME/bin
ENV CODIS_CONF $CODIS_HOME/conf/config.ini
ENV CODIS_GITHUB_URL github.com/wandoulabs/codis
RUN mkdir -p $GOPATH/src/$CODIS_GITHUB_URL \
 && git clone https://$CODIS_GITHUB_URL $GOPATH/src/$CODIS_GITHUB_URL \
 && go get -d $CODIS_GITHUB_URL \
 && cd $GOPATH/src/github.com/wandoulabs/codis \
 && ./bootstrap.sh \
 && mkdir $CODIS_HOME \
 && tar -C $CODIS_HOME -xvf deploy.tar \
 && cd $SRC_DIR && rm -rf $GOPATH \
 && echo '' >> /etc/profile \
 && echo "export CODIS_HOME=$CODIS_HOME" >> /etc/profile \
 && echo "export CODIS_CONF=$CODIS_HOME/conf/config.ini" >> /etc/profile \
 && echo 'export PATH=$PATH:$CODIS_HOME/bin' >> /etc/profile

# Add the codis scripts
ADD conf/codis $CODIS_HOME
RUN chmod a+x $CODIS_HOME/bin/codis-start

# Supervisor
RUN mkdir -p /var/log/supervisor
ADD conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Port
EXPOSE 10087 11000 19000

# Daemon
CMD ["/usr/bin/supervisord"]