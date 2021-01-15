FROM xena/go:1.11.5 AS build
ENV GOPROXY https://cache.greedo.xeserv.us
RUN apk add --no-cache ghc cabal wget build-base \
 && cabal update \
 && cabal install aeson bytestring vector text
WORKDIR /ventriloquist
COPY . .
RUN set -x && mkdir -p /x/bin \
 && apk add --no-cache build-base \
 && GOBIN=/x/bin go install -v ./cmd/ventriloquist \
 && ghc -O2 -o /x/bin/proxy-matcher internal/proxytag/Matcher.hs

FROM xena/alpine
COPY --from=build /x/bin/ventriloquist /usr/local/bin/ventriloquist
COPY --from=build /x/bin/proxy-matcher /usr/local/bin/proxy-matcher
RUN apk add --no-cache so:libgmp.so.10 so:libffi.so.6
VOLUME /data
ENV DB_PATH /data/tulpas.db
CMD ["/usr/local/bin/ventriloquist"]
