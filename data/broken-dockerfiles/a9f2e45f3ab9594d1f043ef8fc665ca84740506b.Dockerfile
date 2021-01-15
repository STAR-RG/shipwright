FROM alpine:latest
RUN apk add --no-cache nodejs
COPY . hyper-tunnel
RUN npm install --production --global ./hyper-tunnel