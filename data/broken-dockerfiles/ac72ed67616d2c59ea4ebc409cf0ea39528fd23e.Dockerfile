FROM        versioneye/ruby-base:2.6.3-1
MAINTAINER  Robert Reiz <reiz@versioneye.com>

RUN rm -Rf /app; \
    mkdir /app

ADD . /app

RUN cp /app/supervisord.conf /etc/supervisord.conf; \
    cd /app/ && bundle install;


CMD /usr/bin/supervisord -c /etc/supervisord.conf
