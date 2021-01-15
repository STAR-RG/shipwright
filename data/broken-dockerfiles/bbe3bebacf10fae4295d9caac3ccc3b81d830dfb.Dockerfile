FROM ubuntu:14.04
MAINTAINER Pine Mizune <pinemz@gmail.com>

EXPOSE 8080

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        gcc \
        libc6-dev \
        libyaml-dev \
        zlib1g-dev \
        libssl-dev

RUN curl http://dist.crystal-lang.org/apt/setup.sh | sudo bash && \
    apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54 && \
    echo "deb http://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list && \
    apt-get install -y crystal

ADD . /opt/slack-invite
WORKDIR /opt/slack-invite

RUN rm -rf libs && \
    rm -rf .crystal && \
    rm -rf .shards && \
    rm -rf bin

RUN git config --global http.sslVerify false && \
    shards install && \
    mkdir -p bin && \
    crystal build src/app.cr -o ./bin/slack-invite --release

RUN apt-get purge -y git curl gcc && \
    apt-get clean -y && \
    rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ENTRYPOINT ./bin/slack-invite --port 8080
