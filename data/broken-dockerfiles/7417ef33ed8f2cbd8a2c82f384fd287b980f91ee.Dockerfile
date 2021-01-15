FROM heroku/heroku:18-build

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# -- Install Pipenv:
RUN apt update && apt upgrade -y && apt install python3.7-dev -y
RUN curl --silent https://bootstrap.pypa.io/get-pip.py | python3.7

# Backwards compatility.
RUN rm -fr /usr/bin/python3 && ln /usr/bin/python3.7 /usr/bin/python3

RUN pip3 install pipenv

# -- Install Application into container:
RUN set -ex && mkdir /bruce
WORKDIR /bruce

# -- Adding Pipfiles
COPY Pipfile Pipfile
COPY Pipfile.lock Pipfile.lock

# Install Docker.
RUN apt install -y docker.io

# Instlall kube-ctl.
RUN apt-get update && apt-get install -y apt-transport-https
RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN touch /etc/apt/sources.list.d/kubernetes.list
RUN echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update
RUN apt-get install -y kubectl

# Install daemontools
RUN apt-get update -qq && apt-get install -qq -y daemontools && apt-get -qq -y --allow-downgrades --allow-remove-essential --allow-change-held-packages dist-upgrade && apt-get clean  && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* /var/tmp/*

# Install Herokuish.
RUN curl --location --silent https://github.com/gliderlabs/herokuish/releases/download/v0.4.4/herokuish_0.4.4_linux_x86_64.tgz | tar -xzC /bin

COPY . /bruce

# -- Install dependencies:
RUN set -ex && pipenv install --deploy --system

RUN pip3 install -e .
CMD bruce-operator watch
VOLUME /var/lib/docker
