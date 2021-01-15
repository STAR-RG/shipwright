FROM golang:1.14.1-alpine3.11 as build

RUN apk add --update make git

WORKDIR /go/src/github.com/mhamrah/grpc-example
COPY . .

#RUN make deps

RUN go build -o bin/todos-server todos/server/cmd/main.go
RUN go build -o bin/todos-client todos/client/cmd/main.go

FROM alpine:3.11 as server

WORKDIR /app

COPY --from=build /go/src/github.com/mhamrah/grpc-example/bin/todos-server /app/server

EXPOSE 50051/tcp

ENTRYPOINT ["/app/server"]


FROM alpine:3.11 as client

WORKDIR /app

COPY --from=build /go/src/github.com/mhamrah/grpc-example/bin/todos-client /app/client

ENTRYPOINT ["/app/client"]
