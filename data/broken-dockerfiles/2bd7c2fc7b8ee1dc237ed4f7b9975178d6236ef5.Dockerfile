# build stage
FROM golang:alpine AS build-env
RUN apk update && apk add make
ADD . /go/src/github.com/kragniz/tor-ingress-controller
RUN cd /go/src/github.com/kragniz/tor-ingress-controller && make

# final stage
FROM alpine
RUN apk update && apk add tor && mkdir -p /run/tor/
WORKDIR /app
COPY --from=build-env /go/src/github.com/kragniz/tor-ingress-controller/tor-ingress-controller /app/
ENTRYPOINT ["./tor-ingress-controller"]
