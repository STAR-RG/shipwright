# Dockerfile for testing the module
FROM node:stretch
MAINTAINER Brian Lee Yung Rowe "rowe@zatonovo.com"

RUN npm install -g ava@next --save-dev && npx ava --init
COPY . /app/arbitrage
WORKDIR /app/arbitrage
