FROM ubuntu:trusty
MAINTAINER Masahiro Nagano <kazeburo@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales
RUN apt-get update \
  && apt-get -y install git cmake libssl-dev \
    libyaml-dev libuv-dev build-essential \
    ca-certificates curl \
  && rm -rf /var/lib/apt/lists/*

# go-start-server
ENV GO_START_SERVER_VERSION 0.0.2
RUN curl -L https://github.com/lestrrat/go-server-starter/releases/download/$GO_START_SERVER_VERSION/start_server_linux_amd64.tar.gz | tar zxv -C /usr/local/bin --strip=1  --wildcards '*/start_server' --no-same-owner --no-same-permissions

# h2o
ENV H2O_VERSION 20150122
RUN git clone https://github.com/h2o/h2o \
  && cd h2o \
  && git submodule update --init --recursive \
  && cmake . \
  && make h2o
COPY h2o.conf /h2o/h2o.conf
COPY start.sh /h2o/start.sh
RUN chmod +x /h2o/start.sh
WORKDIR /h2o
ENV KILL_OLD_DELAY 1

ENTRYPOINT ["/h2o/start.sh"]
CMD ["/h2o/h2o.conf"]
