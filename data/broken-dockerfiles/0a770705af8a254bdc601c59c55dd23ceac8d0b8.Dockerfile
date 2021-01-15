FROM alpine

RUN apk --update add tor haproxy ruby \
  && apk --update add --virtual build-dependencies ruby-bundler ruby-dev ruby-nokogiri \
  && gem install --no-ri --no-rdoc socksify \
  && apk del build-dependencies \
  && rm -rf /var/cache/apk/*


ADD haproxy.cfg.erb /usr/local/etc/haproxy.cfg.erb

ADD start.rb /usr/local/bin/start.rb
RUN chmod +x /usr/local/bin/start.rb

EXPOSE 5566

CMD ruby /usr/local/bin/start.rb
