FROM gjovanov/node-alpine-edge
LABEL maintainer="Goran Jovanov <goran.jovanov@gmail.com>"

# Version
ADD VERSION .

# Environment variables
ENV NODE_ENV production
ENV HOST 0.0.0.0
ENV PORT 3000
ENV API_URL https://facer.xplorify.net

# Install packages & git clone source code and build the application
RUN apk add --update --no-cache --virtual .build-deps \
  gcc g++ make git python && \
  apk add --no-cache vips vips-dev fftw-dev libc6-compat \
  --repository http://nl.alpinelinux.org/alpine/edge/testing/ \
  --repository http://nl.alpinelinux.org/alpine/edge/main && \
  cd / && \
  git clone https://github.com/gjovanov/facer.git && \
  cd /facer && \
  npm i pm2 -g && \
  npm i --production && \
  npm run build && \
  apk del .build-deps vips-dev fftw-dev && \
  rm -rf /var/cache/apk/*

# Volumes
VOLUME /facer/data
WORKDIR /facer

EXPOSE 3000

# Define the Run command
CMD ["npm", "run", "start"]
