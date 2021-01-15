# Gopherfile
# github.com/TheTannerRyan/Gopherfile

FROM golang:alpine as gopherfile
ENV GO111MODULE on

RUN adduser -D -g '' gopher
WORKDIR /data

# certificates + timezone data
RUN apk update
RUN apk --no-cache add ca-certificates tzdata

# dependency management
RUN apk add git

FROM gopherfile as build
COPY . /data

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -mod=vendor -installsuffix cgo -ldflags="-w -s" -o /data/entrypoint

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=build /etc/passwd /etc/passwd
COPY --from=build /data /
USER gopher

ENTRYPOINT ["/entrypoint"]
