FROM ${REGISTRY}/alpine-node:8.11.4

RUN mkdir -p /home/src

EXPOSE 3000

ENV NODE_ENV docker
ENV MONGO_HOST mongo
ENV POSTGRES_HOST postgres

WORKDIR /home/src

COPY . /home/src

CMD node bin/index.js
