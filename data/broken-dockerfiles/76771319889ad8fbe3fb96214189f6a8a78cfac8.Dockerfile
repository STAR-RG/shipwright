# build stage
FROM golang:1.13-alpine AS build-env
RUN apk --no-cache add build-base git bzr mercurial gcc
ENV D=/chainload
WORKDIR $D
# cache dependencies
ADD go.mod $D
ADD go.sum $D
RUN go mod download
# build
ADD . $D
ARG VERSION="unknown"
ENV VERSION=$VERSION
RUN cd $D && go install -ldflags "-X main.version=${VERSION}" ./cmd/chainload

# final stage
FROM alpine
RUN apk add --no-cache ca-certificates curl
WORKDIR /chainload
COPY --from=build-env /go/bin/chainload /usr/local/bin/chainload
ENTRYPOINT ["chainload -human=false"]
