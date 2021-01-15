FROM ubuntu:12.10
MAINTAINER Alex Brandt <alunduil@alunduil.com>

RUN apt-get update
RUN apt-get upgrade -y -qq

RUN apt-get install -y -qq python-pip build-essential python-dev

RUN useradd -c 'added by docker for margarine' -d /usr/local/src/margarine -r margarine
USER margarine

EXPOSE 5000

ADD conf /etc/margarine

ADD . /usr/local/src/margarine

RUN pip install -q -e /usr/local/src/margarine

ENTRYPOINT [ "/usr/local/bin/margarine" ]
CMD [ "tinge", "blend", "spread" ]
