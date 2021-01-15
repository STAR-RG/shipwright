FROM node:6.10

WORKDIR /app
RUN yarn install

RUN yarn global add serverless

EXPOSE 9229

ENTRYPOINT '/bin/bash'
