FROM python:3.6-alpine

RUN apk add --update \
    python \
    python-dev \
    py-pip \
    build-base \
    curl \
    curl-dev \
    libffi-dev \
    bash \
    net-tools \
    heimdal-telnet \
    openssl \
    openssl-dev \
    gcc \
    vim \
    openssh \
    openssh-client \
  && pip install virtualenv

ENV PROJECT_NAME nerfball
ENV START_SCRIPT /opt/nerfball/nerfball/scripts/start-container.sh 
ENV LOG_DIR /opt/logs
ENV CONFIG_DIR /opt/logs
ENV DATA_DIR /opt/logs

RUN mkdir -p -m 777 /opt/nerfball /opt/shared /opt/logs /opt/data /opt/configs /opt/badstuff /tmp/system

WORKDIR /opt/nerfball

COPY nerfball-latest.tgz /opt/nerfball
COPY ./docker/bashrc /root/.bashrc

RUN cd /opt/nerfball && tar xvf nerfball-latest.tgz && ls /opt/nerfball

RUN echo "Starting nerfball build"

RUN cd /opt/nerfball \
  && ls -l /opt/nerfball \
  && virtualenv -p python3 /opt/nerfball/venv \
  && ls -lrt /opt/nerfball/venv/bin \
  && source /opt/nerfball/venv/bin/activate \
  && pip install -e . \
  && /opt/nerfball/nerfball/scripts/nerf-virtualenv.sh /opt/nerfball/venv/bin/python \
  && /opt/nerfball/nerfball/scripts/download-bad-stuff-in-container.sh

# Add in sample config
COPY docker/configs/control.cfg /tmp/system/control.cfg

ENTRYPOINT bash /opt/nerfball/nerfball/scripts/start-container.sh
