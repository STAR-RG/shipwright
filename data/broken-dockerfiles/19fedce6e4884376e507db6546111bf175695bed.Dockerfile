# Best practices for development, and not for a production deployment
# from https://nodejs.org/en/docs/guides/nodejs-docker-webapp/

# Build: run ooni-sysadmin.git/scripts/docker-build from this directory

FROM node:carbon

# BEGIN root
USER root
COPY . /usr/src/app
RUN set -ex \
    && yarn add global grunt-cli \
    && yarn global add loopback-sdk-angular-cli \
    && chown -R node:node /usr/src/app \
    && :
# END root

USER node
WORKDIR /usr/src/app

# .cache removal leads to two times smaller image and 
RUN set -ex \
    && yarn install --frozen-lockfile \
    && npm run build \
    && rm -rf /home/node/.cache \
    && :

EXPOSE 3000

USER daemon
CMD [ "npm", "start" ]
