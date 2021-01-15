FROM debian:jessie

RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-get install -y ca-certificates
RUN apt-get install -y bsdiff git curl

ENV PACKAGE_NAME github.com/getlantern/autoupdate-server

ENV WORKDIR /app
RUN mkdir -p $WORKDIR

ENV GO_VERSION go1.7.3

ENV GOROOT /usr/local/go
ENV GOPATH /go

RUN mkdir -p $GOPATH/bin $GOPATH/src $GOPATH/pkg

ENV PATH $PATH:$GOROOT/bin:$GOPATH/bin

ENV GO_PACKAGE_URL https://storage.googleapis.com/golang/$GO_VERSION.linux-amd64.tar.gz
RUN curl -sSL $GO_PACKAGE_URL | tar -xvzf - -C /usr/local

RUN curl https://glide.sh/get | bash

ENV APPSRC_DIR /go/src/$PACKAGE_NAME
ENV mkdir -p $APPSRC_DIR
COPY ./ $APPSRC_DIR/

RUN cp $APPSRC_DIR/bin/entrypoint.sh /bin/entrypoint.sh

RUN go build -o /bin/autoupdate-server $PACKAGE_NAME
RUN go build -tags mock -o /bin/autoupdate-server-mock $PACKAGE_NAME

VOLUME [ "/keys", $APPSRC_DIR, $WORKDIR ]

WORKDIR $WORKDIR

ENTRYPOINT ["/bin/entrypoint.sh"]
