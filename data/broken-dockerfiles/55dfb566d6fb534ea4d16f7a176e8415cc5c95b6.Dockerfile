from ruby:1.9.3

env DEBIAN_FRONTEND noninteractive

run sed -i '/deb-src/d' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -y build-essential postgresql-client nodejs

run gem install --no-ri --no-rdoc bundler foreman

workdir /tmp
copy Gemfile Gemfile
copy Gemfile.lock Gemfile.lock

run bundle install

workdir /app
