FROM ruby:2.3.5-jessie
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN curl -sS http://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update -qq && apt-get install -y yarn nodejs
RUN mkdir -p /app
WORKDIR /app
RUN node --version

# Unfortunately Debian's packaged version of PhantomJS doesn't work in Docker:
# https://github.com/ariya/phantomjs/issues/14376#issuecomment-239687524
# Hence, we build it ourselves:
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        bzip2 \
        libfontconfig \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
    && mkdir /tmp/phantomjs \
    && curl -L https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
           | tar -xj --strip-components=1 -C /tmp/phantomjs \
    && cd /tmp/phantomjs \
    && mv bin/phantomjs /usr/local/bin \
    && cd \
    && apt-get purge --auto-remove -y \
        curl \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/*

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN ["bundle", "install"]
COPY package.json /app/package.json
RUN ["yarn"]
COPY . /app/
CMD ["rails", "s"]