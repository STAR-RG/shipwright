FROM alpine:3.3

MAINTAINER Jose Armesto <jose@armesto.net>

ENV LANG C.UTF-8
ENV ELASTALERT_HOME /opt/elastalert
ENV RULES_DIRECTORY ${ELASTALERT_HOME}/rules
ENV ELASTALERT_VERSION v0.1.4

ARG vcs_ref="Unknown"
ARG vcs_branch="Unknown"
ARG build_date="Unknown"

LABEL org.label-schema.vcs-type="git" \
      org.label-schema.vcs-url="https://github.com/fiunchinho/docker-elastalert" \
      org.label-schema.vcs-ref=$vcs_ref \
      org.label-schema.vcs-branch=$vcs_branch \
      org.label-schema.docker.dockerfile=/Dockerfile \
      org.label-schema.build-date=$build_date

WORKDIR /opt

RUN apk add --update \
    ca-certificates \
    python \
    python-dev \
    py-pip \
    build-base \
  && rm -rf /var/cache/apk/*

RUN wget https://github.com/Yelp/elastalert/archive/${ELASTALERT_VERSION}.zip && \
    unzip -- *.zip && \
    mv -- elast* ${ELASTALERT_HOME} && \
    rm -- *.zip

WORKDIR ${ELASTALERT_HOME}

# Install Elastalert.
RUN python setup.py install && \
    pip install -e . && \
    mkdir ${RULES_DIRECTORY}

ENTRYPOINT ["/opt/elastalert/docker-entrypoint.sh"]
CMD ["python", "elastalert/elastalert.py", "--verbose"]

COPY ./Dockerfile /
COPY ./docker-entrypoint.sh ${ELASTALERT_HOME}/docker-entrypoint.sh
COPY ./config.yaml ${ELASTALERT_HOME}/config.yaml

ADD ./rules ${RULES_DIRECTORY}/