FROM golang:latest
MAINTAINER Kaisar Arkhan <yukinagato@protonmail.com>

COPY . /go/src/cherry-pick-bot
WORKDIR /go/src/cherry-pick-bot

RUN go get -d -v
RUN go install -v

CMD ["/go/src/cherry-pick-bot/docker/run.sh"]
