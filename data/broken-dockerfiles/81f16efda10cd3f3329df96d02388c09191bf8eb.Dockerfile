FROM debian:7
MAINTAINER Federico Gonzalez <https://github.com/fedeg>

# Install packages
RUN apt-get update -qq \
 && apt-get install -y procps curl ruby-dev libsqlite3-dev ruby1.9.3 make git build-essential libxml2 zlib1g-dev liblzma-dev patch libxml2-dev libxslt-dev pkg-config libgmp-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install dependencies
RUN gem install bundler therubyracer execjs

# Install nodejs
ENV NODE_VERSION 0.10.46
RUN curl -sL https://deb.nodesource.com/setup_0.10 | bash -
RUN apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate folders
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy files and install
ADD Gemfile /usr/src/app/
ADD Gemfile.lock /usr/src/app/
ADD config* /usr/src/app/
RUN bundle install
ADD . /usr/src/app

CMD [ "foreman", "start" ]
