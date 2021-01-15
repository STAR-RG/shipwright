FROM ruby:2.6.3
MAINTAINER Gregg Kellogg <gregg@greggkellogg.net>

WORKDIR /var/www/
COPY . /var/www/

# for nokogiri
RUN apt-get install -y libxml2-dev libxslt1-dev

# for a JS runtime
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -qq && apt-get install -qq --no-install-recommends \
    nodejs \
    yarn \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Ruby dependencies
ENV LANG C.UTF-8
RUN gem install bundler:2.0.2
RUN npm install
RUN bundle install

# Start server
ENV PORT 80
EXPOSE 80
CMD ["foreman", "start"]
