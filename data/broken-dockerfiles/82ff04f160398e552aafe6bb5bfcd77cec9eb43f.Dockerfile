FROM cloudgear/build-deps:14.04
MAINTAINER Georg Kunz, CloudGear <contact@cloudgear.net>

# Use a version available on the Brightbox repo (https://www.brightbox.com/docs/ruby/ubuntu/)
ENV RUBY_VERSION 2.2

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C3173AA6 && \
    echo deb http://ppa.launchpad.net/brightbox/ruby-ng/ubuntu trusty main > /etc/apt/sources.list.d/brightbox-ruby-ng-trusty.list && \
    apt-get update -q && apt-get install -yq --no-install-recommends \
        ruby$RUBY_VERSION \
        ruby$RUBY_VERSION-dev && \

    # clean up
    rm -rf /var/lib/apt/lists/* && \
    truncate -s 0 /var/log/*log && \

    # Setup Rubygems
    echo 'gem: --no-document' > /etc/gemrc && \
    gem install bundler && gem update --system

CMD ["/usr/bin/ruby"]