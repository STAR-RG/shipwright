FROM debian:jessie
MAINTAINER PotHix
RUN apt-get update && apt-get install -y --force-yes build-essential python-dev make python-pip devscripts node equivs

RUN mkdir -p /simplestack/debian
ADD debian/control /simplestack/debian/control

# install package dependencies
RUN mk-build-deps -r -i -t 'apt-get --force-yes -y --no-install-recommends' /simplestack/debian/control

WORKDIR /simplestack

EXPOSE 8081
VOLUME /simplestack

ADD pip-requires /simplestack/pip-requires
ADD dev.makefile /simplestack/dev.makefile

RUN make -f dev.makefile bootstrap

CMD ["make", "-f", "dev.makefile", "server"]
