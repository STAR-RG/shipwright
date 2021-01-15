FROM docker.io/golang:1.13 as build

RUN set -x; \
    apt-get update \
 && apt-get install -y \
      bzip2 \
      ca-certificates \
      gcc \
      git \
      wget \
 && git clone https://github.com/vshn/restic \
 && cd restic \
 && git checkout 2319-dump-dir-tar \
 && go run -mod=vendor build.go -v \
 && mv restic /usr/local/bin/restic \
 && chmod +x /usr/local/bin/restic \
 && mkdir /.cache \
 && chmod -R 777 /.cache

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go test -v ./...
ENV CGO_ENABLED=0
RUN go install -v ./...

# runtime image
FROM docker.io/alpine:3
WORKDIR /app

RUN mkdir /.cache && chmod -R g=u /.cache
RUN apk --no-cache add ca-certificates

COPY --from=build /usr/local/bin/restic /usr/local/bin/restic
COPY --from=build /go/bin/wrestic /app/

ENTRYPOINT [ "./wrestic" ]
