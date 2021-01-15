FROM ubuntu:xenial as openedx
RUN apt update && \
  apt install -y git-core language-pack-en python python-pip python-dev apparmor-utils build-essential curl g++ gcc ipython pkg-config rsyslog libmysqlclient-dev libffi-dev libssl-dev && \
  pip3 install --upgrade pip setuptools && \
  rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV PID /var/tmp/notifier-celery-workers.pid

WORKDIR /edx/app/notifier
COPY requirements /edx/app/notifier/requirements
RUN pip install -r requirements/base.txt

RUN useradd -m --shell /bin/false app
USER app
CMD python manage.py scheduler
COPY . /edx/app/notifier

FROM openedx as edx.org
RUN pip install newrelic
CMD newrelic-admin run-program python manage.py scheduler
