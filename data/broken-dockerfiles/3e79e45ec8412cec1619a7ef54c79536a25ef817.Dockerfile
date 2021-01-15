# syntax=docker/dockerfile:experimental
FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:3.10

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

LABEL maintainer="CrazyMax" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/crazy-max/docker-svn2git-mirror" \
  org.opencontainers.image.source="https://github.com/crazy-max/docker-svn2git-mirror" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="CrazyMax" \
  org.opencontainers.image.title="svn2git-mirror" \
  org.opencontainers.image.description="Mirror SVN repositories to Git periodically" \
  org.opencontainers.image.licenses="MIT"

RUN apk --update --no-cache add \
    cyrus-sasl \
    cyrus-sasl-dev \
    cyrus-sasl-digestmd5 \
    git \
    git-perl \
    git-svn \
    jq \
    openssh \
    openssh-client \
    perl-git-svn \
    ruby \
    shadow \
    subversion \
    tzdata \
  && gem install specific_install --no-ri --no-rdoc \
  && gem specific_install https://github.com/mfherbst/svn2git.git \
  #&& gem install svn2git --no-ri --no-rdoc \
  && rm -rf /var/cache/apk/* /tmp/*

ENV SVN2GIT_MIRROR_PATH="/etc/svn2git-mirror" \
  SVN2GIT_MIRROR_CONFIG="/etc/svn2git-mirror/config.json" \
  DATA_PATH="/data"

COPY entrypoint.sh /entrypoint.sh
COPY assets /

RUN mkdir -p ${SVN2GIT_MIRROR_PATH} ${DATA_PATH} \
  && addgroup -g 1000 svn2git \
  && adduser -u 1000 -G svn2git -h /home/svn2git -s /sbin/nologin -D svn2git \
  && chmod a+x /entrypoint.sh /usr/local/bin/*

WORKDIR ${DATA_PATH}
VOLUME [ "${DATA_PATH}" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "busybox", "crond", "-f", "-L", "/dev/stdout" ]
