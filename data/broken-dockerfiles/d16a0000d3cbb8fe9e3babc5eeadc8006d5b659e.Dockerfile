FROM debian:jessie
MAINTAINER Seigo Uchida <spesnova@gmail.com> (@spesnova)

WORKDIR /app

# Install ruby 2.1.5p273 (2014-11-13) [x86_64-linux-gnu]
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      zlib1g-dev \
      libpq-dev \
      ruby2.1-dev \
      ruby=1:2.1.5 \
      nodejs=0.10.29~dfsg-2 && \
    rm -rf /var/lib/apt/lists/* && \
    gem install bundler --no-ri --no-rdoc

COPY Gemfile      /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install -j4

COPY . /app
RUN bundle exec rake assets:precompile RAILS_ENV=production

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
