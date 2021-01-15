FROM ruby:1.9.3
RUN mkdir -p /usr/src/the-video-store
WORKDIR /usr/src/the-video-store
ENV RAILS_ENV development
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true
COPY Gemfile /usr/src/the-video-store
COPY Gemfile.lock /usr/src/the-video-store
RUN gem install bundler -v '1.17.3'
RUN bundle install
COPY . /usr/src/the-video-store
RUN mkdir -p public/media/image public/media/video media/image media/video
RUN printf "deb http://archive.debian.org/debian/ jessie main\ndeb-src http://archive.debian.org/debian/ jessie main\ndeb http://security.debian.org jessie/updates main\ndeb-src http://security.debian.org jessie/updates main" > /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -y sqlite3 vim --no-install-recommends && rm -rf /var/lib/apt/lists/*
EXPOSE 9393
CMD ["bundle", "exec", "shotgun", "--host=0.0.0.0"]

