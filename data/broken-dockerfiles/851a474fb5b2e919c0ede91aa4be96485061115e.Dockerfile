FROM node:10
MAINTAINER dryajov

# setup app dir
RUN mkdir -p /kitsunet/
WORKDIR /kitsunet/

# install dependencies
COPY ./package.json /kitsunet/package.json
RUN npm install

# copy over app dir
COPY ./definitions /kitsunet/definitions
COPY ./src /kitsunet/src
COPY ./bin /kitsunet/bin

#COPY ./tscondig-prod.json /kitsunet/tscondig-prod.json
COPY ./tsconfig.json /kitsunet/tsconfig.json

RUN npm run build

ADD ./misc/monkey.json /kitsunet/

# start server
CMD node dist/bin/cli.js \
  -a /ip4/127.0.0.1/tcp/30334/ws \
  -a /ip4/127.0.0.1/tcp/30333 \
  -d 10 \
  -p 8e99 \
  -p 1372 \
  -e 0x6810e776880C02933D47DB1b9fc05908e5386b96 \
  -r http://134.209.53.104:8546  \
  -b -t -i `pwd`/monkey.json \
  -D ./monkey

# expose server
EXPOSE 30333
EXPOSE 30334
