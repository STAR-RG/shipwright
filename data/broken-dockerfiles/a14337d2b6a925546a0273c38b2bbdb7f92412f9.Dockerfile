FROM alpine:3.4

ARG BUILD_DATE
ARG VCS_REF
ARG PUPPET_VERSION

LABEL \
    org.label-schema.name="jumanjiman/puppet" \
    org.label-schema.description="Run Puppet inside a container such that it affects the state of the underlying host" \
    org.label-schema.url="https://github.com/jumanjihouse/puppet-on-coreos" \
    org.label-schema.vcs-url="https://github.com/jumanjihouse/puppet-on-coreos.git" \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.vcs-type="Git" \
    org.label-schema.license="MIT" \
    org.label-schema.build-date=${BUILD_DATE} \
    org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.version=${PUPPET_VERSION}

# Puppet absolutely needs the shadow utils, such as useradd.
RUN echo http://dl-4.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories

# Get access to ruby < 2.2 to avoid syck errors on puppet 3.x
RUN echo http://dl-4.alpinelinux.org/alpine/v3.1/main/ >> /etc/apk/repositories

RUN apk upgrade --update --available && \
    apk add --no-cache -X http://dl-4.alpinelinux.org/alpine/edge/main/ \
      libressl \
      && \
    apk add --no-cache -X http://dl-4.alpinelinux.org/alpine/edge/community/ \
      shadow \
      && \
    apk add \
      ca-certificates \
      dmidecode \
      pciutils \
      'ruby<2.2' \
      util-linux \
    && rm -f /var/cache/apk/* && \
    gem install -N \
      facter:'>= 2.4.6' \
      puppet:"= ${PUPPET_VERSION}" \
    && rm -fr /root/.gem

RUN rm -fr /var/spool/cron/crontabs/* && \
    :

ENV container docker
VOLUME ["/sys/fs/cgroup", "/run", "/var/lib/puppet", "/lib64"]

ENTRYPOINT ["/usr/bin/puppet"]
CMD ["help"]
