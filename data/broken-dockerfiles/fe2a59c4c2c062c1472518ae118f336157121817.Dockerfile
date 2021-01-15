FROM golang:1.4.2
MAINTAINER takasing
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -fr /var/cache/apt/archives/* /var/lib/apt/lists/*
COPY . /go/src/golang-gin-api
RUN go get github.com/tools/godep
RUN go get -u github.com/pilu/fresh
WORKDIR /go/src/golang-gin-api
RUN godep restore
RUN go install
EXPOSE 8080
CMD ["sh", "-c", "fresh"]
