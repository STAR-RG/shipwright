FROM golang:1.8.3-alpine
RUN apk add --no-cache ca-certificates
RUN set -ex \
	&& apk add --no-cache --virtual .build-deps \
		git make 

RUN git config --global http.https://gopkg.in.followRedirects true
RUN go get -v github.com/tools/godep
RUN go get -d -v github.com/hawkingrei/g53
RUN cd ${GOPATH}/src/github.com/hawkingrei/g53 && godep restore && make docker
EXPOSE 80
EXPOSE 53/udp
ENTRYPOINT ["g53","--verbose"]

