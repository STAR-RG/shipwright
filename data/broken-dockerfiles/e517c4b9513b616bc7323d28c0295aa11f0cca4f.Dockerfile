# Copyright 2018 Adobe
# All Rights Reserved.

# NOTICE: Adobe permits you to use, modify, and distribute this file in
# accordance with the terms of the Adobe license agreement accompanying
# it. If you have received this file from a source other than Adobe,
# then your use, modification, or distribution of it requires the prior
# written permission of Adobe. 

FROM golang:1.10-alpine
ARG FLAVOURS
ARG VERSION
ARG DATE
ARG SHA
COPY . /go/src/github.com/adobe/sledgehammer/
COPY ./installer/compile.sh /
RUN apk add --no-cache bash && \
    CGO_ENABLED=0 go build -ldflags "-X main.flavours=$FLAVOURS -X github.com/adobe/sledgehammer/slh/version.Version=$VERSION" -o ./bin/slh-installer ./src/github.com/adobe/sledgehammer/installer && \
    /compile.sh ${FLAVOURS} ${VERSION} ${DATE} ${SHA}}

FROM alpine
WORKDIR /root/

COPY --from=0 /go/bin/slh-* /slh/
RUN apk upgrade && apk add --no-cache ca-certificates
CMD ["/slh/slh-installer"]