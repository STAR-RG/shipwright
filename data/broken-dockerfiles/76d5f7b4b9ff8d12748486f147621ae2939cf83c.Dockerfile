FROM gcr.io/google_containers/ubuntu-slim:0.14
MAINTAINER Yusuke KUOKA <ykuoka@gmail.com>

# Disable prompts from apt.
ENV DEBIAN_FRONTEND noninteractive

ENV FLUENTD_VERSION %%FLUENTD_VERSION%%

# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apt remove --purge -y build*' has no effect
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && wget https://github.com/just-containers/s6-overlay/releases/download/v1.17.1.1/s6-overlay-amd64.tar.gz --no-check-certificate -O /tmp/s6-overlay.tar.gz \
 && tar xvfz /tmp/s6-overlay.tar.gz -C / \
 && rm -f /tmp/s6-overlay.tar.gz \
 && apt-get install --no-install-recommends -y \
                    procps \
                    build-essential \
                    ca-certificates \
                    git \
                    ruby \
                    ruby-dev \
                    libjemalloc1 && \
    echo 'gem: --no-document' >> /etc/gemrc && \
    echo "Running ruby: $(ruby -v)" && \
    # minitest 5.x is required by activesupport. It is not a development dependency but a runtime dependency.
    # minitest 5.x should be bundled in ruby since 2.2 but ruby from ubuntu seems to miss it therefore install it ourselves
    gem install minitest oj && \
    gem install fluentd -v $FLUENTD_VERSION && \
    # We install fluent plugins here because doing so requires build-base and ruby-dev in order to build native extensions
    gem install fluent-plugin-google-cloud && \
    gem install fluent-plugin-datadog-log -v 0.1.0.rc18 && \
    gem install fluent-plugin-kubernetes_metadata_filter && \
    gem install fluent-plugin-record-reformer && \
    gem install fluent-plugin-prometheus && \
    apt-get remove --purge -y wget build-essential ruby-dev git libgcc-5-dev cpp-5 && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN adduser --disabled-password --disabled-login --gecos "" --uid 1000 --home /home/fluent fluent
RUN chown fluent:fluent -R /home/fluent

# for log storage (maybe shared with host)
RUN mkdir -p /fluentd/log
# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins

RUN chown -R fluent:fluent /fluentd

USER fluent
WORKDIR /home/fluent

# Tell ruby to install packages as user
RUN echo "gem: --user-install --no-document" >> ~/.gemrc
ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH
ENV GEM_PATH /home/fluent/.gem/ruby/2.3.0:$GEM_PATH

USER root
WORKDIR /

COPY rootfs /

ENV JEMALLOC_PATH /usr/lib/x86_64-linux-gnu/libjemalloc.so.1
ENV LD_PRELOAD $JEMALLOC_PATH

ENV FLUENTD_OUT_KUBEUSER_BUFFER_OVERFLOW_ACTION="block"
ENV FLUENTD_OUT_KUBEUSER_BUFFER_CHUNK_LIMIT_SIZE="2M"
ENV FLUENTD_OUT_KUBEUSER_BUFFER_TOTAL_LIMIT_SIZE="16M"
ENV FLUENTD_OUT_KUBEUSER_BUFFER_FLUSH_INTERVAL="10s"
ENV FLUENTD_OUT_KUBEUSER_BUFFER_RETRY_MAX_INTERVAL="30"
ENV FLUENTD_OUT_KUBEUSER_RETRY_FOREVER="false"
ENV FLUENTD_OUT_KUBEUSER_RETRY_MAX_TIMES="50"
ENV FLUENTD_OUT_KUBEUSER_FLUSH_THREAD_COUNT="2"

ENV FLUENTD_OUT_KUBESYS_BUFFER_OVERFLOW_ACTION="block"
ENV FLUENTD_OUT_KUBESYS_BUFFER_CHUNK_LIMIT_SIZE="2M"
ENV FLUENTD_OUT_KUBESYS_BUFFER_TOTAL_LIMIT_SIZE="16M"
ENV FLUENTD_OUT_KUBESYS_BUFFER_FLUSH_INTERVAL="30s"
ENV FLUENTD_OUT_KUBESYS_BUFFER_RETRY_MAX_INTERVAL="30"
ENV FLUENTD_OUT_KUBESYS_RETRY_FOREVER="false"
ENV FLUENTD_OUT_KUBESYS_RETRY_MAX_TIMES="50"
ENV FLUENTD_OUT_KUBESYS_FLUSH_THREAD_COUNT="2"

ENV FLUENTD_ARGS=""
ENV FLUENTD_CONF="fluent.conf"

EXPOSE 24224 5140

# Prometheus metrics endpoint
EXPOSE 24231

ENTRYPOINT [ "/init" ]

CMD /bin/s6-envuidgid fluent fluentd -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_ARGS
