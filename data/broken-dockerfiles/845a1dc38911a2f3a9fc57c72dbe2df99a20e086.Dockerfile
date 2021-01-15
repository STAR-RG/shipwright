FROM ubuntu

COPY ./go-ethereum /home/go-ethereum
WORKDIR /home/go-ethereum/

RUN apt-get update
RUN apt-get install -y build-essential libgmp3-dev golang-1.9 golang-1.9-doc git
RUN ln /usr/lib/go-1.9/bin/go /usr/bin/go

RUN git checkout refs/tags/v1.7.3
RUN make geth
RUN cp build/bin/geth /usr/local/bin/

WORKDIR /home/DATA_STORE/
COPY ./genesis.json /home/DATA_STORE
COPY ./static-nodes.json /home/DATA_STORE

RUN geth --datadir "/home/DATA_STORE" init /home/DATA_STORE/genesis.json
