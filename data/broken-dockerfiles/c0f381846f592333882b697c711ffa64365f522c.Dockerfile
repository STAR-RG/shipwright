FROM golang:alpine

RUN apk update && apk add --no-cache git

WORKDIR "/opt"

RUN go get github.com/rakyll/statik

COPY . .

RUN statik -src=.deploy/swaggerui/

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o release/faas-swagger .
 
FROM alpine:3.8

WORKDIR "/opt"

COPY --from=0  /opt/release/faas-swagger /opt/

RUN chmod 777 /opt/*

CMD ["/opt/faas-swagger"]
