#
## Builds pyethapp from GitHub in a python 2.7.9 docker container.
## Note: base image, do not use in a production environment
##
## Build with:
#
#  docker build -t pyethapp .
#
##
## Run with:
# 
# docker run -p 30303:30303 -p 30303:30303/udp pyethapp
#
## Data volume
#
# To preserve data across container recreations mount a volume at /data e.g:
#
# docker run -v /somewhere/on/the/host:/data pyethapp
#

FROM python:2.7.9

RUN apt-get update
RUN apt-get install -y git-core

RUN git clone https://github.com/ethereum/pyrlp /apps/pyrlp
WORKDIR /apps/pyrlp
RUN pip install -e .

RUN git clone https://github.com/ethereum/pydevp2p /apps/pydevp2p
WORKDIR /apps/pydevp2p
RUN pip install -e .

RUN git clone https://github.com/ethereum/pyethereum /apps/pyethereum
WORKDIR /apps/pyethereum
RUN pip install -e .

RUN git clone https://github.com/ethereum/pyethapp /apps/pyethapp
WORKDIR /apps/pyethapp
RUN pip install -e .

# Fix debian's ridiculous gevent-breaking constant removal
# (e.g. https://github.com/hypothesis/h/issues/1704#issuecomment-63893295):
RUN sed -i 's/PROTOCOL_SSLv3/PROTOCOL_SSLv23/g' /usr/local/lib/python2.7/site-packages/gevent/ssl.py

RUN mkdir /data

EXPOSE 4000
EXPOSE 30303
EXPOSE 30303/udp

VOLUME /data

ENTRYPOINT ["pyethapp"]
CMD ["-d", "/data", "run"]
