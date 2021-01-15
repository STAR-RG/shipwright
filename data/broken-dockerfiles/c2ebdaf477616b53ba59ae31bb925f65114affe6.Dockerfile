FROM debian:latest
ARG RUBY_URL
ARG MIRROR_DEBIAN
ENV app /app
RUN mkdir $app
ADD . $app
WORKDIR $app
RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev build-essential git zlib1g-dev liblzma-dev net-tools" && \
    echo "$http_proxy $no_proxy" && set -x && [ -z "$MIRROR_DEBIAN" ] || \
     sed -i.orig -e "s|http://deb.debian.org\([^[:space:]]*\)|$MIRROR_DEBIAN/debian9|g ; s|http://security.debian.org\([^[:space:]]*\)|$MIRROR_DEBIAN/debian9-security|g" /etc/apt/sources.list ; \
  apt-get update -qq && \
  apt-get install -qy --no-install-recommends $buildDeps && \
   ( set -ex ; echo 'gem: --no-document' >> /etc/gemrc && \
    [ -z "$http_proxy" ] || gem_args=" $gem_args -r -p $http_proxy " ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -r https://rubygems.org/ ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -a $RUBY_URL ; \
    [ -z "$RUBY_URL" ] || sudo -E gem source -c ; \
    sudo -E gem sources ; \
    sudo -E gem install -V --no-rdoc --no-ri $gem_args bundler ) && \
    [  -z "$RUBY_URL" ] || bundle config mirror.https://rubygems.org $RUBY_URL ; \
    bundler install && \
    bundle exec rake test && \
    bundle exec rake build
