FROM node:lts as node

COPY . /root

WORKDIR /root/web/static/app
RUN curl -o- -L https://yarnpkg.com/install.sh | sh
RUN yarn install
RUN yarn build

FROM golang as go

COPY --from=node /root /root

WORKDIR /root
RUN curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s -- -b $(go env GOPATH)/bin v1.19.1
RUN go get -u github.com/gobuffalo/packr/v2/packr2

WORKDIR /root
ENV GO111MODULE on

CMD ["./build.sh", "all"]
