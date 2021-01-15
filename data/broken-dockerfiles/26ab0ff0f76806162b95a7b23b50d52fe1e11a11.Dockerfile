FROM golang:latest
MAINTAINER Sam Whited <swhited@atlassian.com>

# Use Yelp dumb-init to handle signals
ADD https://github.com/Yelp/dumb-init/releases/download/v1.0.1/dumb-init_1.0.1_amd64 /usr/bin/dumb-init
RUN chmod +x /usr/bin/dumb-init

RUN mkdir -p /go/src/github.com/jitsi

COPY ./ /go/src/github.com/jitsi/jap

RUN go get -u github.com/jitsi/jap/cmd/jap

RUN go build github.com/jitsi/jap/cmd/jap
RUN go install github.com/jitsi/jap/cmd/jap

WORKDIR /go/src/github.com/jitsi/jap/cmd/jap

EXPOSE 8080

CMD ["dumb-init", "jap", "-http", ":8080"]
