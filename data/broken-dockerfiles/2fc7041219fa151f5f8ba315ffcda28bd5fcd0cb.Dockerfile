FROM ibmcom/swift-ubuntu:latest

LABEL name "now-swift-example"

RUN mkdir /app
WORKDIR /app
COPY Package.swift /app
COPY Sources /app
COPY .swift-version /app
RUN swift build

EXPOSE 3000

USER root

CMD [".build/debug/app"]
