FROM blacklabelops/java:openjre.8

# Image Build Date By Buildsystem
ARG BUILD_DATE=undefined
ARG CROW_VERSION=1.0-SNAPSHOT

ENV CROW_HOME=/opt/crow/ \
    CROW_GLOBAL_PROPERTY_PREFIX=CRONIUM_ \
    CROW_JOB_PROPERTY_PREFIX=JOB \
    CRONIUM_HOME=/opt/cronium \
    DOCKER_VERSION=18.03.0-ce \
    JAVA_OPTS=-Xmx64m \
    DOCKER_HOST=unix:///var/run/docker.sock

RUN apk add --update --no-cache --virtual .build-deps \
      curl && \
    mkdir -p ${CROW_HOME} && \
    mkdir -p ${CRONIUM_HOME} && \
    curl -fsSL https://57-112953069-gh.circle-artifacts.com/0/root/crow/application/target/crow-application-0.5-SNAPSHOT.jar -o ${CROW_HOME}/crow-application.jar && \
    curl -L -o /tmp/docker-${DOCKER_VERSION}.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && tar -xz -C /tmp -f /tmp/docker-${DOCKER_VERSION}.tgz && mv /tmp/docker/docker /usr/local/bin && \
    chmod +x /usr/local/bin/docker && \
    # Cleanup
    apk del .build-deps && \
    rm -rf /var/cache/apk/* && rm -rf /tmp/* && rm -rf /var/log/*

COPY imagescripts ${CROW_HOME}

RUN cp ${CROW_HOME}/cronium.sh /usr/bin/cronium && \
    chmod +x /usr/bin/cronium

# Image Metadata
LABEL com.blacklabelops.application.cronium.version=$CROW_VERSION \
      com.blacklabelops.image.builddate.cronium=${BUILD_DATE}

EXPOSE 8080
WORKDIR ${CRONIUM_HOME}
ENTRYPOINT ["/sbin/tini","--","/opt/crow/docker-entrypoint.sh"]
CMD ["cronium-server"]
