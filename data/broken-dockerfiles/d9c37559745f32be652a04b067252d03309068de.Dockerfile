FROM alpine:latest as builder
LABEL builder=true
MAINTAINER John Belamaric <jbelamaric@infoblox.com> @johnbelamaric

RUN apk add --update g++ make git bind bind-dev openssl-dev \
    libxml2-dev libcap-dev json-c-dev libcrypto1.0

RUN git clone https://github.com/akamai/dnsperf
RUN cd dnsperf && ./configure && make && strip dnsperf resperf
RUN git clone https://gitlab.isc.org/isc-projects/bind9.git
RUN cd bind9 && git checkout v9_12_1 && cd contrib/queryperf && ./configure && make && strip queryperf

FROM alpine:latest
ENV PS1="dnstools# "
RUN apk --update add bind-tools curl jq tcpdump libcrypto1.0 && rm -rf /var/cache/apk/*

COPY --from=builder /dnsperf/dnsperf /bin
COPY --from=builder /dnsperf/resperf /bin
COPY --from=builder /bind9/contrib/queryperf /bin

ENTRYPOINT ["/bin/sh"]
