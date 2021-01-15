FROM elixir:1.3.2
MAINTAINER Maxence Decrosse <maxence.decrosse@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive
ENV MIX_ENV prod
ENV PORT 4000
ENV HOSTNAME http://localhost:4000
ENV SLACK_TOKEN 123
ENV SOUNDCLOUD_CLIENT_ID 123

# Installs ffmpeg
RUN echo "deb http://ftp.uk.debian.org/debian jessie-backports main" | tee /etc/apt/sources.list.d/jessie-backports.list
RUN apt-get update
RUN apt-get -t jessie-backports install -y ffmpeg
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl

# Installs goon (porcelain)
RUN \
  wget https://github.com/alco/goon/releases/download/v1.1.1/goon_linux_amd64.tar.gz && \
  tar xvfz goon_linux_amd64.tar.gz && \
  mv goon /usr/local/bin/goon && \
  rm goon*

# Installs hex
RUN mix local.hex --force

# Installs rebar
RUN mix local.rebar --force

WORKDIR /app

COPY mix.exs /app/
COPY mix.lock /app/

RUN mix do deps.get, compile

COPY config /app/config
COPY lib /app/lib
COPY priv /app/priv

CMD ["mix", "do", "compile,", "run", "--no-halt"]
