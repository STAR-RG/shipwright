FROM alpine
MAINTAINER Patricio Bruna <pbruna@itlinux.cl>

ENV BUILD_PACKAGES bash curl-dev ruby-dev build-base git libxml2-dev
ENV RUBY_PACKAGES ruby ruby-io-console ruby-bundler
ENV LANG=en_US.UTF-8

# Update and install all of the required packages.
# At the end, remove the apk cache
RUN apk update && \
    apk upgrade && \
    apk add $BUILD_PACKAGES && \
    apk add $RUBY_PACKAGES && \
    rm -rf /var/cache/apk/*

RUN mkdir /usr/app
WORKDIR /usr/app

ADD . /usr/app
COPY Gemfile /usr/app/
COPY Gemfile.lock /usr/app/
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install


ENTRYPOINT ["/usr/bin/bundle", "exec", "rackup"]
CMD ["-p", "9292", "-o", "0.0.0.0"]

EXPOSE 9292
