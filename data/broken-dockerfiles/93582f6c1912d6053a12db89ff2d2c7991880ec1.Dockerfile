# build stage
FROM golang as builder

ENV GO111MODULE=on

WORKDIR /go/src/github.com/herdius/herdius-core/


COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build

# final stage
FROM scratch
COPY --from=builder /go/src/github.com/herdius/herdius-core/cmd/herserver /herserver/
EXPOSE 3000
ENTRYPOINT ["/herserver"]
