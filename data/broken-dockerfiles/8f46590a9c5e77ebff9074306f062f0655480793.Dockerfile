FROM rawmind/alpine-jvm8:1.8.181-1
MAINTAINER Raul Sanchez <rawmind@gmail.com>

ENV SERVICE_NAME=zk \
    SERVICE_HOME=/opt/zk \
    SERVICE_CONF=/opt/zk/conf/zoo.cfg \
    SERVICE_VERSION=3.4.12 \
    SERVICE_USER=zookeeper \
    SERVICE_UID=10002 \
    SERVICE_GROUP=zookeeper \
    SERVICE_GID=10002 \
    SERVICE_VOLUME=/opt/tools \
    PATH=/opt/zk/bin:${PATH}

# Install service software
RUN SERVICE_RELEASE=zookeeper-${SERVICE_VERSION} && \
    mkdir -p ${SERVICE_HOME}/logs ${SERVICE_HOME}/data && \
    cd /tmp && \
    apk --update add jq gnupg tar patch && \
    eval $(gpg-agent --daemon) && \
    curl -sSLO "https://dist.apache.org/repos/dist/release/zookeeper/${SERVICE_RELEASE}/${SERVICE_RELEASE}.tar.gz" && \
    curl -sSLO https://dist.apache.org/repos/dist/release/zookeeper/${SERVICE_RELEASE}/${SERVICE_RELEASE}.tar.gz.asc && \
    curl -sSL  https://dist.apache.org/repos/dist/release/zookeeper/KEYS | gpg -v --import - && \
    gpg -v --verify ${SERVICE_RELEASE}.tar.gz.asc && \
    tar -zx -C ${SERVICE_HOME} --strip-components=1 --no-same-owner -f ${SERVICE_RELEASE}.tar.gz && \
    apk del jq gnupg tar patch && \
    rm -rf \
      /tmp/* \
      /root/.gnupg \
      /var/cache/apk/* \
      ${SERVICE_HOME}/contrib/fatjar \
      ${SERVICE_HOME}/dist-maven \
      ${SERVICE_HOME}/docs \
      ${SERVICE_HOME}/src \
      ${SERVICE_HOME}/bin/*.cmd && \
    addgroup -g ${SERVICE_GID} ${SERVICE_GROUP} && \
    adduser -g "${SERVICE_NAME} user" -D -h ${SERVICE_HOME} -G ${SERVICE_GROUP} -s /sbin/nologin -u ${SERVICE_UID} ${SERVICE_USER} 
ADD root /
RUN chmod +x ${SERVICE_HOME}/bin/*.sh \
  && chown -R ${SERVICE_USER}:${SERVICE_GROUP} ${SERVICE_HOME} /opt/monit

USER $SERVICE_USER
WORKDIR $SERVICE_HOME

EXPOSE 2181 2888 3888

HEALTHCHECK CMD monit summary | grep OK | grep -q zk-service || exit 1
