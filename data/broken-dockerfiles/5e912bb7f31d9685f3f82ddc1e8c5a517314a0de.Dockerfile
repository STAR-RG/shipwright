FROM haskell:8.2

RUN apt-get update
RUN apt-get install xz-utils make

RUN mkdir -p /root/media-goggler
WORKDIR /root/media-goggler

# Fetch dependencies
COPY server/stack.yaml ./
RUN stack upgrade
RUN stack setup
COPY server/package.yaml ./

# Download dependencies first
RUN mkdir src && echo "module Main where\nimport Protolude\nmain = return ()" > src/Main.hs
RUN stack build
RUN rm src/Main.hs

COPY server/src/ src/
RUN stack install

FROM node:8

RUN mkdir -p /root/media-goggler
WORKDIR /root/media-goggler

COPY client/package.json ./
RUN npm install

COPY client/ ./
RUN npm run build

FROM debian
RUN apt-get update
RUN apt-get install libgmp10 netbase

WORKDIR /root/
COPY --from=0 /root/.local/bin/media-goggler /root/media-goggler
COPY --from=1 /root/media-goggler/build/ /root/public/
CMD ["./media-goggler"]
