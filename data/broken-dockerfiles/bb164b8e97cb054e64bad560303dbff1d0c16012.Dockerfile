FROM golang:1.4-cross

MAINTAINER George Lewis <schvin@schvin.net>
MAINTAINER Charlie Lewis <defermat@defermat.net>

ENV REFRESHED_AT 2015-01-24

RUN apt-get update && apt-get install -y \
    git \
    nodejs \
    npm

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN mkdir -p /go/src/github.com/yaronn
RUN git clone https://github.com/yaronn/blessed-contrib.git /go/src/github.com/yaronn/blessed-contrib
WORKDIR /go/src/github.com/yaronn/blessed-contrib
RUN npm install
ADD . /go/src/github.com/tubesandlube/bron
RUN go get github.com/tubesandlube/bron

WORKDIR /go/src/github.com/tubesandlube/bron
RUN cp -R dashboards ../../yaronn/blessed-contrib/

ENTRYPOINT ["/go/bin/bron"]
CMD [""]
