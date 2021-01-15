FROM ubuntu:14.10

RUN apt-get -y update && apt-get install -y \
  git \
  mercurial \
  bzr \
  wget \
  python \
  build-essential \
  make \
  gcc \
  python-dev \
  locales \
  python-pip \
  zip \
  curl

ENV LC_ALL C.UTF-8

RUN curl https://storage.googleapis.com/golang/go1.4.1.linux-amd64.tar.gz |tar -C /usr/local -xz
ENV PATH /usr/local/go/bin/:/work/bin:$PATH
RUN mkdir /workspace
RUN mkdir -p /work/src/github.com/ulrichSchreiner/ /work/pkg /work/bin
WORKDIR /work
ENV GOPATH /work
RUN go get code.google.com/p/go.net/websocket && \ 
  go get github.com/emicklei/go-restful && \
  go get github.com/ulrichSchreiner/gdbmi && \
  go get github.com/jayschwa/go-pty && \
  go get launchpad.net/loggo

RUN cd src/github.com/ulrichSchreiner && git clone https://github.com/ulrichSchreiner/carpo.git
RUN cd src/github.com/ulrichSchreiner/carpo/qx/carpo/source && git clone https://github.com/qooxdoo/qooxdoo.git 
RUN cd src/github.com/ulrichSchreiner/carpo/qx/carpo/source/qooxdoo && git checkout branch_3_0_x
RUN cd src/github.com/ulrichSchreiner/carpo/cmd && ./createdist

WORKDIR /workspace

ENV GOPATH /workspace
VOLUME ["/workspace"]
EXPOSE 8080
ENTRYPOINT ["/work/src/github.com/ulrichSchreiner/carpo/cmd/dist/carpo"]
CMD ["-port=8080"]
