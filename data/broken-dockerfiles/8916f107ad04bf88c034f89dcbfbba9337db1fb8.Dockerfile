FROM ubuntu:16.04

RUN apt-get update && apt-get install -y ruby-dev libffi-dev apache2 git build-essential libxml2-dev zlib1g-dev && gem install bundler -v '~> 1.11'

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /etc/apache2
ENV APACHE_PID_FILE /etc/apache2.pid

ENV APP_HOME /var/www/html
ENV BUILD_DIR /opt/jekyll/
ADD Gemfile $BUILD_DIR
ADD *.gemspec $BUILD_DIR
WORKDIR $BUILD_DIR
RUN bundle install
ADD . $BUILD_DIR
RUN rm -rf Gemfile.lock
RUN bundle exec rake --trace gen_site
RUN cp -ar $BUILD_DIR/_site/* $APP_HOME


CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
