##################################  Notes  ##################################
# to build:
#   docker build --no-cache -t photon .
# (--no-cache is required or else it won't pull latest updates from github)
#
# to run:
#   docker run -p 35556:35556  photon
#
# to run with a mounted directory for ~/.photon:
#   docker run -p 35556:35556 -v /path/to/a/local/directory:/root/.photon eccoind
#
#############################################################################

FROM ubuntu:16.04

MAINTAINER Dylan Aird Version 1

RUN apt-get update && apt-get install -y libdb-dev libdb++-dev build-essential libtool autotools-dev automake pkg-config libssl-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev libminiupnpc-dev libzmq3-dev git unzip wget
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

#build from latest refactor12 branch code

RUN git clone https://github.com/photonproject/photon.git

RUN cd photon/src/leveldb && chmod +x Makefile && chmod +x build_detect_platform && make libleveldb.a libmemenv.a

RUN mkdir photon/src/obj

RUN cd photon/src/ && make -f makefile.unix

RUN mkdir /root/.photon/ && cd /root/.photon/ && echo "rpcuser=photonrpc" >>  photon.conf && echo "rpcpassword=3CAiCFyJmmjUWX2tuQYPh4NpowkUkkTfiev5if9qwBkq" >>  photon.conf

EXPOSE 35556

CMD ["/photon/src/photond","-listen","-upnp"]
