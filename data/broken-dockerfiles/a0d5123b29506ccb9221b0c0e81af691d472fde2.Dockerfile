FROM ruby:2.2.5-slim

MAINTAINER Micros <micros@atlassian.com>

COPY .gemrc /root/

# Temporary pin google-protobuf to 3.0.0.alpha.4.0
# There are some concerns on the performance of the latest version
RUN apt-get update -y && apt-get install -yy \
      build-essential \
      zlib1g-dev \
      libjemalloc1 && \
    gem install fluentd:0.12.23 && \
    gem install google-protobuf -v 3.0.0.alpha.4.0 --pre && \
      fluent-gem install \
      fluent-plugin-ec2-metadata:0.0.9 \
      fluent-plugin-hostname:0.0.2 \
      fluent-plugin-retag:0.0.1 \
      fluent-plugin-kinesis:1.0.1 \
      fluent-plugin-elasticsearch:1.4.0 \
      fluent-plugin-record-modifier:0.4.1 \
      fluent-plugin-multi-format-parser:0.0.2 \
      fluent-plugin-kinesis-aggregation:0.2.2 \
      fluent-plugin-concat:0.4.0 \
      fluent-plugin-parser:0.6.1 \
      fluent-plugin-statsd-event:0.1.1 && \
    apt-get purge -y build-essential && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/log/fluent

# port monitor forward debug
EXPOSE 24220   24224   24230

ENV LD_PRELOAD "/usr/lib/x86_64-linux-gnu/libjemalloc.so.1"
CMD ["fluentd", "-c", "/etc/fluent/fluentd.conf"]
