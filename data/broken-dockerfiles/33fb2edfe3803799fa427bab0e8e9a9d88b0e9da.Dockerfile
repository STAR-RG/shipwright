FROM ubuntu:16.04

WORKDIR /work

# Install pre-requisites
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 && \
    echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" \
       >> /etc/apt/sources.list.d/ethereum.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
            git \
            libssl-dev \
            solc && \
    apt-get install -y \
            python-pip && \
    rm -rf /var/lib/apt/lists/*

# We use the local Git submodule for the Raiden build.
COPY raiden/ raiden/

# Build Raiden client
RUN cd raiden && \
    pip install --upgrade -r requirements.txt && \
    python setup.py develop

# Build the client Web UI - seems to be non-functional at the moment.
#RUN apt-get install -y --no-install-recommends \
#            curl && \
#    curl -sL https://deb.nodesource.com/setup_7.x | bash - && \
#    apt-get install -y nodejs && \
#    cd raiden && \
#    python setup.py compile_webui && \
#    apt-get remove curl

EXPOSE 5001 40001

ENTRYPOINT ["/usr/local/bin/raiden"]
