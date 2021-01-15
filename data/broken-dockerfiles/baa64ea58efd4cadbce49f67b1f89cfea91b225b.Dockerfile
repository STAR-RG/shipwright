FROM sebp/elk:562

RUN \
  /opt/logstash/bin/plugin update logstash-input-beats

ADD 02-beats-input.conf /etc/logstash/conf.d/

ADD 15-heritrix.conf /etc/logstash/conf.d/

EXPOSE 5601 9200 9300 5000 5044

