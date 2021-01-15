FROM ubuntu:16.04 AS openvino
LABEL maintainer="yourorganizationhere"

RUN apt-get update && apt-get install -y --no-install-recommends \
            git software-properties-common lsb-release build-essential cmake pkg-config wget sudo cpio libcurl4-openssl-dev libssl-dev && \
            rm -rf /var/lib/apt/lists/*

ARG OPENVINO_DOWNLOAD_URL 
ENV OPENVINO_DOWNLOAD_URL $OPENVINO_DOWNLOAD_URL

RUN wget -O /tmp/openvino.tar.gz ${OPENVINO_DOWNLOAD_URL} && \
        tar -xzf /tmp/openvino.tar.gz -C /tmp && \
        rm /tmp/openvino.tar.gz && \
        cd /tmp/l_openvino_toolkit* && \
        ./install_cv_sdk_dependencies.sh && \
        sed -i 's/^\(ACCEPT_EULA\)=.*$/\1=accept/' silent.cfg && \
        ./install.sh -s silent.cfg && \
        rm -rf /tmp/l_openvino*

###################
#  Go + OpenVINO  #
###################
FROM openvino AS openvino-go
LABEL maintainer="yourorganizationhere"

ARG GOVERSION=1.11.2
ENV GOVERSION $GOVERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
            git software-properties-common && \
            wget https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz && \
            tar -C /usr/local -xzf go${GOVERSION}.linux-amd64.tar.gz && \
            rm go${GOVERSION}.linux-amd64.tar.gz && \
            mkdir -p $HOME/go/bin && mkdir -p $HOME/go/src && mkdir -p $HOME/go/pkg && \
            rm -rf /var/lib/apt/lists/*

ENV GOPATH=$HOME/go
ENV PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

WORKDIR $GOPATH

#####################
#  OpenVINO Go app  #
#####################
FROM openvino-go AS openvino-go-app
LABEL maintainer="yourorganizationhere"

COPY . /go/src/github.com/hybridgroup/monitor
WORKDIR /go/src/github.com/hybridgroup/monitor

RUN mkdir -p $GOPATH/bin && \
            wget -O- https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN chmod +x build.sh && \
            ./build.sh "go"

COPY docker-entrypoint.sh /usr/local/bin/
RUN ln -s usr/local/bin/docker-entrypoint.sh / && \
            chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["-h"]
