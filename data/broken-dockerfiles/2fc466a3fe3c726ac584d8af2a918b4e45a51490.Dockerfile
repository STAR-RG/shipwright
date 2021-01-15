FROM golang:1.4
MAINTAINER Quinn Slack <sqs@sourcegraph.com>

ADD . /go/src/sourcegraph.com/sourcegraph/xconf
WORKDIR /go/src/sourcegraph.com/sourcegraph/xconf
RUN go get -d -v
RUN go install

USER www-data

EXPOSE 5400
ENTRYPOINT ["/go/bin/xconf"]
